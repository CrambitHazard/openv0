import Link from 'next/link'

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-16">
        <div className="text-center">
          <h1 className="text-6xl font-bold text-gray-900 mb-6">
            OpenV0
          </h1>
          <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
            Transform your ideas into fully functional websites with the power of AI
          </p>
          
          <div className="space-y-4">
            <Link 
              href="/generator" 
              className="btn-primary text-lg px-8 py-3"
            >
              Start Building
            </Link>
            
            <div className="text-sm text-gray-500">
              Powered by OpenRouter & DeepSeek
            </div>
          </div>
        </div>
        
        <div className="mt-16 grid md:grid-cols-3 gap-8">
          <div className="card">
            <div className="card-header">
              <h3 className="card-title">AI-Powered</h3>
              <p className="card-description">
                Uses advanced AI models to understand your requirements and generate code
              </p>
            </div>
          </div>
          
          <div className="card">
            <div className="card-header">
              <h3 className="card-title">Real-time Preview</h3>
              <p className="card-description">
                See your website come to life with live preview as the AI generates code
              </p>
            </div>
          </div>
          
          <div className="card">
            <div className="card-header">
              <h3 className="card-title">No Authentication</h3>
              <p className="card-description">
                Start building immediately - just add your OpenRouter API key and begin
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
