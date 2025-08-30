-- =====================================================
-- Sample Data for Development and Testing
-- OpenV0 Database Sample Data
-- =====================================================

-- =====================================================
-- Sample Projects
-- =====================================================

INSERT INTO projects (id, name, description, prompt, status, framework, features, metadata) VALUES
(
    '550e8400-e29b-41d4-a716-446655440001',
    'Portfolio Website',
    'A modern portfolio website with dark theme and animations',
    'Create a portfolio website with dark theme, modern animations, and responsive design. Include sections for about, projects, skills, and contact. Use smooth scrolling and hover effects.',
    'completed',
    'react',
    '["responsive", "dark-theme", "animations", "smooth-scroll"]',
    '{"complexity": "medium", "estimated_time": "2 hours", "preferences": {"color_scheme": "dark", "style": "modern"}}'
),
(
    '550e8400-e29b-41d4-a716-446655440002',
    'E-commerce Landing Page',
    'A landing page for an e-commerce store',
    'Design a landing page for an e-commerce store selling tech gadgets. Include hero section, product showcase, testimonials, and call-to-action buttons. Make it mobile-friendly.',
    'in_progress',
    'vue',
    '["responsive", "mobile-first", "cta-buttons", "testimonials"]',
    '{"complexity": "high", "estimated_time": "3 hours", "preferences": {"color_scheme": "light", "style": "professional"}}'
),
(
    '550e8400-e29b-41d4-a716-446655440003',
    'Blog Template',
    'A clean and minimal blog template',
    'Create a clean and minimal blog template with a sidebar, featured posts section, and pagination. Use a readable font and plenty of white space.',
    'pending',
    'vanilla',
    '["minimal", "readable", "sidebar", "pagination"]',
    '{"complexity": "low", "estimated_time": "1 hour", "preferences": {"color_scheme": "light", "style": "minimal"}}'
);

-- =====================================================
-- Sample Generation Sessions
-- =====================================================

INSERT INTO generation_sessions (id, project_id, status, plan_data, execution_log, current_step, progress, started_at, completed_at) VALUES
(
    '660e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440001',
    'completed',
    '{
        "steps": [
            {
                "id": "step_1",
                "type": "setup",
                "title": "Project Setup",
                "description": "Initialize React project with Vite and configure Tailwind CSS",
                "dependencies": [],
                "estimated_time": 30,
                "order": 1
            },
            {
                "id": "step_2",
                "type": "layout",
                "title": "Layout Structure",
                "description": "Create main layout components and navigation",
                "dependencies": ["step_1"],
                "estimated_time": 45,
                "order": 2
            },
            {
                "id": "step_3",
                "type": "components",
                "title": "Section Components",
                "description": "Build individual sections (About, Projects, Skills, Contact)",
                "dependencies": ["step_2"],
                "estimated_time": 120,
                "order": 3
            }
        ],
        "total_estimated_time": 195,
        "framework": "react",
        "features": ["responsive", "dark-theme", "animations"]
    }',
    '[
        {
            "step_id": "step_1",
            "status": "completed",
            "started_at": "2024-01-15T10:30:00Z",
            "completed_at": "2024-01-15T10:32:00Z",
            "execution_time": 120,
            "result": "Project setup completed successfully"
        },
        {
            "step_id": "step_2",
            "status": "completed",
            "started_at": "2024-01-15T10:32:00Z",
            "completed_at": "2024-01-15T10:35:00Z",
            "execution_time": 180,
            "result": "Layout structure created"
        },
        {
            "step_id": "step_3",
            "status": "completed",
            "started_at": "2024-01-15T10:35:00Z",
            "completed_at": "2024-01-15T10:45:00Z",
            "execution_time": 600,
            "result": "All sections completed"
        }
    ]',
    'step_3',
    100,
    '2024-01-15T10:30:00Z',
    '2024-01-15T10:45:00Z'
),
(
    '660e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440002',
    'in_progress',
    '{
        "steps": [
            {
                "id": "step_1",
                "type": "setup",
                "title": "Vue Project Setup",
                "description": "Initialize Vue project with Vite and configure styling",
                "dependencies": [],
                "estimated_time": 25,
                "order": 1
            },
            {
                "id": "step_2",
                "type": "hero",
                "title": "Hero Section",
                "description": "Create compelling hero section with product showcase",
                "dependencies": ["step_1"],
                "estimated_time": 60,
                "order": 2
            }
        ],
        "total_estimated_time": 180,
        "framework": "vue",
        "features": ["responsive", "mobile-first", "cta-buttons"]
    }',
    '[
        {
            "step_id": "step_1",
            "status": "completed",
            "started_at": "2024-01-15T11:00:00Z",
            "completed_at": "2024-01-15T11:02:00Z",
            "execution_time": 120,
            "result": "Vue project setup completed"
        },
        {
            "step_id": "step_2",
            "status": "in_progress",
            "started_at": "2024-01-15T11:02:00Z",
            "completed_at": null,
            "execution_time": null,
            "result": "Creating hero section..."
        }
    ]',
    'step_2',
    50,
    '2024-01-15T11:00:00Z',
    NULL
);

-- =====================================================
-- Sample Preview States
-- =====================================================

INSERT INTO preview_states (id, session_id, html_content, css_content, js_content, metadata, is_active) VALUES
(
    '770e8400-e29b-41d4-a716-446655440001',
    '660e8400-e29b-41d4-a716-446655440001',
    '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portfolio - John Doe</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-900 text-white">
    <nav class="fixed w-full bg-gray-800 bg-opacity-90 backdrop-blur-sm z-50">
        <div class="max-w-6xl mx-auto px-4">
            <div class="flex justify-between items-center py-4">
                <h1 class="text-2xl font-bold">John Doe</h1>
                <div class="hidden md:flex space-x-8">
                    <a href="#about" class="hover:text-blue-400 transition-colors">About</a>
                    <a href="#projects" class="hover:text-blue-400 transition-colors">Projects</a>
                    <a href="#skills" class="hover:text-blue-400 transition-colors">Skills</a>
                    <a href="#contact" class="hover:text-blue-400 transition-colors">Contact</a>
                </div>
            </div>
        </div>
    </nav>
    
    <main>
        <section id="hero" class="min-h-screen flex items-center justify-center">
            <div class="text-center">
                <h2 class="text-6xl font-bold mb-4">Hi, I''m John Doe</h2>
                <p class="text-xl text-gray-300 mb-8">Full Stack Developer & Designer</p>
                <button class="bg-blue-600 hover:bg-blue-700 px-8 py-3 rounded-lg transition-colors">
                    View My Work
                </button>
            </div>
        </section>
    </main>
</body>
</html>',
    '/* Custom styles for portfolio */
body {
    scroll-behavior: smooth;
}

.nav-link {
    position: relative;
}

.nav-link::after {
    content: '''';
    position: absolute;
    bottom: -5px;
    left: 0;
    width: 0;
    height: 2px;
    background: #3b82f6;
    transition: width 0.3s ease;
}

.nav-link:hover::after {
    width: 100%;
}

/* Smooth animations */
.fade-in {
    animation: fadeIn 1s ease-in;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}',
    '// Smooth scrolling for navigation links
document.querySelectorAll(''a[href^="#"]'').forEach(anchor => {
    anchor.addEventListener(''click'', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute(''href''));
        if (target) {
            target.scrollIntoView({
                behavior: ''smooth'',
                block: ''start''
            });
        }
    });
});

// Add fade-in animation to sections
const observerOptions = {
    threshold: 0.1,
    rootMargin: ''0px 0px -50px 0px''
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add(''fade-in'');
        }
    });
}, observerOptions);

document.querySelectorAll(''section'').forEach(section => {
    observer.observe(section);
});',
    '{"step_id": "step_3", "version": "1.0", "framework": "react", "features": ["responsive", "dark-theme", "animations"]}',
    true
),
(
    '770e8400-e29b-41d4-a716-446655440002',
    '660e8400-e29b-41d4-a716-446655440002',
    '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechGadgets - Premium Tech Store</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-white">
    <header class="bg-blue-600 text-white">
        <div class="max-w-6xl mx-auto px-4 py-6">
            <div class="flex justify-between items-center">
                <h1 class="text-3xl font-bold">TechGadgets</h1>
                <nav class="hidden md:flex space-x-6">
                    <a href="#" class="hover:text-blue-200 transition-colors">Home</a>
                    <a href="#" class="hover:text-blue-200 transition-colors">Products</a>
                    <a href="#" class="hover:text-blue-200 transition-colors">About</a>
                    <a href="#" class="hover:text-blue-200 transition-colors">Contact</a>
                </nav>
            </div>
        </div>
    </header>
    
    <main>
        <section class="bg-gradient-to-r from-blue-600 to-purple-600 text-white py-20">
            <div class="max-w-6xl mx-auto px-4 text-center">
                <h2 class="text-5xl font-bold mb-6">Premium Tech Gadgets</h2>
                <p class="text-xl mb-8">Discover the latest in technology with our curated collection</p>
                <button class="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors">
                    Shop Now
                </button>
            </div>
        </section>
    </main>
</body>
</html>',
    '/* Custom styles for e-commerce */
.gradient-bg {
    background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
}

.btn-primary {
    transition: all 0.3s ease;
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
}

/* Responsive design */
@media (max-width: 768px) {
    .hero-title {
        font-size: 2.5rem;
    }
}',
    '// Mobile menu toggle
const mobileMenuBtn = document.querySelector(''.mobile-menu-btn'');
const mobileMenu = document.querySelector(''.mobile-menu'');

if (mobileMenuBtn && mobileMenu) {
    mobileMenuBtn.addEventListener(''click'', () => {
        mobileMenu.classList.toggle(''hidden'');
    });
}

// Smooth scroll for navigation
document.querySelectorAll(''a[href^="#"]'').forEach(anchor => {
    anchor.addEventListener(''click'', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute(''href''));
        if (target) {
            target.scrollIntoView({
                behavior: ''smooth''
            });
        }
    });
});',
    '{"step_id": "step_2", "version": "0.5", "framework": "vue", "features": ["responsive", "mobile-first", "cta-buttons"]}',
    true
);

-- =====================================================
-- Comments for Documentation
-- =====================================================

COMMENT ON TABLE projects IS 'Sample projects for development and testing';
COMMENT ON TABLE generation_sessions IS 'Sample generation sessions with realistic data';
COMMENT ON TABLE preview_states IS 'Sample preview states with actual HTML/CSS/JS content';

-- =====================================================
-- Usage Notes
-- =====================================================

/*
SAMPLE DATA USAGE:

1. These sample records provide realistic data for testing
2. The HTML/CSS/JS content demonstrates the expected output format
3. The JSON data shows the structure for plan_data and execution_log
4. Use these samples to test API endpoints and frontend components
5. The data includes various statuses to test different scenarios

TESTING SCENARIOS:

- Completed project with full generation history
- In-progress project with partial execution
- Pending project ready for generation
- Multiple preview states for real-time updates
- Various frameworks and feature combinations

CLEANUP:

To remove sample data, run:
DELETE FROM preview_states WHERE id LIKE '770e8400%';
DELETE FROM generation_sessions WHERE id LIKE '660e8400%';
DELETE FROM projects WHERE id LIKE '550e8400%';
*/
