//
//  BookReeadingView.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 15/10/24.
//

import SwiftUI
import WebKit
import SwiftData

struct BookReadingView: View {
    @StateObject private var viewModel: BookReadingViewModel
    @Binding var isTabBarShowing: Bool
    @Environment(\.modelContext) private var context
    @Query var trackBooks: [TrackingBook]
    @State var isTracking: Bool = false
    
    let id: Int
    let book: Book
    
    init(id: Int, book: Book, isTabBarShowing: Binding<Bool>) {
        self.id = id
        self.book = book
        self._isTabBarShowing = isTabBarShowing
        self._viewModel = StateObject(wrappedValue: BookReadingViewModel(bookId: id))
    }
    
    var body: some View {
        let cacheURL = convertToCacheURL(from: id)
        
        VStack {
            if let cacheURL = cacheURL, let url = URL(string: cacheURL) {
                CustomWebView(url: url, viewModel: viewModel, isTracking: $isTracking)
            } else {
                Text("Invalid URL")
                    .foregroundColor(.red)
            }
            
            if isTracking {
                ProgressView(value: viewModel.progress, total: 100)
                    .padding()
                Text("Progress: \(Int(viewModel.progress))%")
            } else {
                Text("This book is not being tracked.")
                    .padding()
            }
        }
        .onDisappear {
            if isTracking {
                viewModel.saveProgress()
                
                if let trackBook = trackBooks.first(where: { $0.bookId == book.id }) {
                    trackBook.progress = viewModel.progress
                }
            }
        }
        .onAppear {
            isTabBarShowing = false
            if let trackBook = trackBooks.first(where: { $0.bookId == book.id }) {
                isTracking = true
                viewModel.progress = trackBook.progress
            } else {
                isTracking = false
                viewModel.loadProgress()
            }
            print(isTracking)
        }
    }
    
    func convertToCacheURL(from id: Int) -> String? {
        return "https://www.gutenberg.org/cache/epub/\(id)/pg\(id)-images.html"
    }
}

class BookReadingViewModel: ObservableObject {
    @Published var progress: Double = 0
    @Published var debugMessage: String = ""
    let bookId: Int
    
    init(bookId: Int) {
        self.bookId = bookId
        loadProgress()
    }
    
    func saveProgress() {
        UserDefaults.standard.set(progress, forKey: "readingProgress_\(bookId)")
        debugMessage = "Progress saved: \(progress)"
        print(debugMessage)
    }
    
    func loadProgress() {
        progress = UserDefaults.standard.double(forKey: "readingProgress_\(bookId)")
        debugMessage = "Progress loaded: \(progress)"
        print(debugMessage)
    }
    
    func updateProgress(_ newProgress: Double) {
        DispatchQueue.main.async {
            self.progress = min(max(newProgress, 0), 100)
            self.debugMessage = "Progress updated: \(self.progress)"
            print(self.debugMessage)
        }
    }
}
struct CustomWebView: UIViewRepresentable {
    let url: URL
    @ObservedObject var viewModel: BookReadingViewModel
    @Binding var isTracking: Bool

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "scrollHandler")
        config.userContentController.add(context.coordinator, name: "debugHandler")
        config.userContentController.add(context.coordinator, name: "errorHandler")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: CustomWebView
        
        init(_ parent: CustomWebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard parent.isTracking else { return }
            
            switch message.name {
            case "scrollHandler":
                if let progress = message.body as? Double {
                    print("Progress received from web view: \(progress)")
                    parent.viewModel.updateProgress(progress)
                }
            case "debugHandler":
                if let message = message.body as? String {
                    print("Debug message from WebView: \(message)")
                    parent.viewModel.debugMessage = message
                }
            case "errorHandler":
                if let error = message.body as? String {
                    print("Error from WebView: \(error)")
                    parent.viewModel.debugMessage = "WebView Error: \(error)"
                }
            default:
                break
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.viewModel.debugMessage = "Page loaded"
            print("Page loaded successfully")

            if parent.isTracking {
                let initialProgress = parent.viewModel.progress
                let script = """
                (function() {
                     try {
                           console.log("Initializing progress tracking...");
                           var lastProgress = \(initialProgress);  // Initialize with previously saved progress

                           function updateProgress() {
                               let scrollPosition = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
                               let totalHeight = document.documentElement.scrollHeight - window.innerHeight;

                               if (totalHeight <= 0) {
                                   console.error("Total height is zero or negative.");
                                   window.webkit.messageHandlers.errorHandler.postMessage("Total height is zero or negative.");
                                   return; // Prevent division by zero
                               }

                               let currentProgress = Math.min(Math.max((scrollPosition / totalHeight) * 100, 0), 100);
                               window.webkit.messageHandlers.scrollHandler.postMessage(currentProgress);
                               lastProgress = currentProgress;
                               window.webkit.messageHandlers.debugHandler.postMessage("Progress updated: " + currentProgress);
                           }

                           function setInitialScrollPosition() {
                               console.log("Setting initial scroll position...");
                               let totalHeight = document.documentElement.scrollHeight - window.innerHeight;

                               if (totalHeight <= 0) {
                                   console.error("Cannot set initial scroll position: Total height is zero or negative.");
                                   window.webkit.messageHandlers.errorHandler.postMessage("Cannot set initial scroll position: Total height is zero or negative.");
                                   return;
                               }

                               let initialScrollPosition = (lastProgress / 100) * totalHeight;
                               window.scrollTo(0, initialScrollPosition);
                               console.log("Set initial position to: ", initialScrollPosition);
                               window.webkit.messageHandlers.debugHandler.postMessage("Set initial position to: " + initialScrollPosition);
                               updateProgress();
                           }

                           function debounce(func, wait) {
                               let timeout;
                               return function() {
                                   clearTimeout(timeout);
                                   timeout = setTimeout(func, wait);
                               }
                         }
                
                           window.addEventListener('scroll', debounce(updateProgress, 100));
                
                           // Use setTimeout to ensure the content is fully loaded before setting the scroll position
                           setTimeout(setInitialScrollPosition, 100);
                
                           console.log("Progress script initialized.");
                           window.webkit.messageHandlers.debugHandler.postMessage("Progress script initialized.");
                
                       } catch (error) {
                           console.error("Script error: ", error);
                           window.webkit.messageHandlers.errorHandler.postMessage(error.toString());
                       }
                   })();
                """
                
                webView.evaluateJavaScript(script) { (result, error) in
                }
            } else {
                print("Skipping progress calculation because the book is not being tracked.")
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.viewModel.debugMessage = "Page load failed: \(error.localizedDescription)"
            print("Page load failed: \(error.localizedDescription)")
        }
    }
}


//#Preview {
//    BookReadingView(id: 1513)
//}
