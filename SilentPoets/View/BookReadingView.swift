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
                CustomWebView(url: url, viewModel: viewModel)
            } else {
                Text("Invalid URL")
                    .foregroundColor(.red)
            }
            ProgressView(value: viewModel.progress, total: 100)
                .padding()
            Text("Progress: \(Int(viewModel.progress))%")
            Text("Debug: \(viewModel.debugMessage)")
        }
        .onDisappear {
            viewModel.saveProgress()
            if let trackBook = trackBooks.first(where: { $0.bookId == book.id }) {
                trackBook.progress = viewModel.progress
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
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "scrollHandler")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: CustomWebView
        
        init(_ parent: CustomWebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "scrollHandler" {
                if let progress = message.body as? Double {
                    print("Progress received from web view: \(progress)")
                    parent.viewModel.updateProgress(progress)
                }
            } else if message.name == "debugHandler" {
                if let message = message.body as? String {
                    print("Debug message from WebView: \(message)")
                    parent.viewModel.debugMessage = message
                }
            } else if message.name == "errorHandler" {
                if let error = message.body as? String {
                    print("Error from WebView: \(error)")
                    parent.viewModel.debugMessage = "WebView Error: \(error)"
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.viewModel.debugMessage = "Page loaded"
            print("Page loaded successfully")
            
            let initialProgress = parent.viewModel.progress
            let script = """
                try {
                    console.log("Initializing progress tracking...");
                    var lastProgress = \(initialProgress);  // Initialize with previously saved progress

                    function updateProgress() {
                        let scrollPosition = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
                        let totalHeight = document.documentElement.scrollHeight - window.innerHeight;

                        if (totalHeight <= 0) {
                            console.error("Total height is zero or negative.");
                            return; // Prevent division by zero
                        }

                        let currentProgress = Math.min(Math.max((scrollPosition / totalHeight) * 100, 0), 100);
                        window.webkit.messageHandlers.scrollHandler.postMessage(currentProgress);  // Send progress to Swift
                        lastProgress = currentProgress;  // Update last known progress
                    }

                    function restoreScrollPosition() {
                        console.log("Restoring scroll position...");
                        let totalHeight = document.documentElement.scrollHeight - window.innerHeight;

                        // Safety check to prevent division by zero
                        if (totalHeight <= 0) {
                            console.error("Cannot restore scroll position: Total height is zero or negative.");
                            return;
                        }

                        // Calculate the initial scroll position based on saved progress
                        let initialScrollPosition = (lastProgress / 100) * totalHeight;
                        window.scrollTo(0, initialScrollPosition);  // Scroll to the saved position
                        console.log("Restored to position: ", initialScrollPosition);
                    }

                    // Debounce function to limit the frequency of progress updates
                    function debounce(func, wait) {
                        let timeout;
                        return function() {
                            clearTimeout(timeout);
                            timeout = setTimeout(func, wait);
                        };
                    }

                    // Attach event listener for scroll updates with debounce
                    window.addEventListener('scroll', debounce(updateProgress, 100));  // Debounce scroll updates

                    // On page load, restore scroll position and update progress
                    window.addEventListener('load', function() {
                        restoreScrollPosition();  // Restore saved scroll position
                        updateProgress();  // Ensure progress is updated after restoring the scroll
                        console.log("Progress script initialized.");
                    });

                } catch (error) {
                    console.error("Script error: ", error);
                    window.webkit.messageHandlers.errorHandler.postMessage(error.toString());  // Send error message to Swift
                }
            """

            
            
            webView.evaluateJavaScript(script) { (result, error) in
                if let error = error {
                    print("Error injecting script: \(error.localizedDescription)")
                    self.parent.viewModel.debugMessage = "Script injection failed: \(error.localizedDescription)"
                    
                    // Try to get more details about the error
                    let errorScript = """
                    if (typeof lastError !== 'undefined') {
                        lastError.toString();
                    } else {
                        "No detailed error information available";
                    }
                    """
                    webView.evaluateJavaScript(errorScript) { (result, _) in
                        if let detailedError = result as? String {
                            print("Detailed error: \(detailedError)")
                            self.parent.viewModel.debugMessage += "\nDetailed error: \(detailedError)"
                        }
                    }
                } else {
                    print("Script injected successfully")
                    self.parent.viewModel.debugMessage = "Script injected successfully"
                }
            }
        }
        
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.viewModel.debugMessage = "Page load failed: \(error.localizedDescription)"
            print("Page load failed: \(error.localizedDescription)")
            
            if let url = webView.url {
                print("Failed URL: \(url.absoluteString)")
            } else {
                print("No URL loaded")
            }
            
            let nsError = error as NSError
            print("Error code: \(nsError.code), domain: \(nsError.domain)")
        }
    }
}

//#Preview {
//    BookReadingView(id: 1513)
//}
