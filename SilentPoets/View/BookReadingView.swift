//
//  BookReeadingView.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 15/10/24.
//

import SwiftUI
import WebKit

struct BookReadingView: View {
    var urlString: String
    @State private var progress: Double = 0
    
    
    var body: some View {
        let url = URL(string: "\(urlString)")!
        VStack {
            WebView(url: url, progress: $progress)
            //                ProgressView(value: progress, total: 100)
            //                Text("Progress: \(Int(progress))%")
        }
        .onDisappear {
            saveProgress()
        }
        .onAppear {
            loadProgress()
            print(urlString)
            
        }
        
        
        
        
        
    }
    private func saveProgress() {
        UserDefaults.standard.set(progress, forKey: "readingProgress")
    }
    
    private func loadProgress() {
        progress = UserDefaults.standard.double(forKey: "readingProgress")
    }
}


struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var progress: Double
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // Enable pinch to zoom
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 4.0
        webView.scrollView.delegate = context.coordinator
        
        webView.load(URLRequest(url: url))
        
        // Inject JavaScript to calculate scroll progress
        let script = WKUserScript(source: """
            function calculateScrollProgress() {
                let scrollPosition = window.pageYOffset;
                let totalHeight = document.documentElement.scrollHeight - window.innerHeight;
                let progress = (scrollPosition / totalHeight) * 100;
                window.webkit.messageHandlers.scrollHandler.postMessage(progress);
            }
            window.addEventListener('scroll', calculateScrollProgress);
            """, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(context.coordinator, name: "scrollHandler")
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "scrollHandler", let progress = message.body as? Double {
                DispatchQueue.main.async {
                    self.parent.progress = min(max(progress, 0), 100)
                }
            }
        }
    }
}


#Preview {
    BookReadingView(urlString: "https://www.gutenberg.org/cache/epub/2000/pg2000-images.html")
}
