module.exports = {
  content: [
    "./app/views/**/*.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.{js,jsx,ts,tsx}",
    "./app/assets/stylesheets/**/*.css",
    "./app/assets/tailwind/**/*.css",
    "./app/assets/builds/**/*.css"
  ],
  safelist: [
    // Sidebar collapsible states
    "sidebar-open:w-64", "sidebar-closed:w-16",
    
    // Brand colors
    "bg-brand", "text-brand", "bg-brand/10", "bg-brand-10",
    "hover:bg-brand/80", "focus:ring-brand",

    // Accent orange colors and shadows (required by spec)
    "bg-accent-orange", "bg-accent-orange-dark", "hover:bg-accent-orange-dark",
    "ring-accent-orange", "shadow-orange-soft", "shadow-orange-strong",
    
    // Neutral colors (required by spec)
    "text-neutral-700", "text-neutral-600", "bg-neutral-50", "bg-neutral-100"
  ],
  theme: {
    extend: {
      colors: {
        // keep your existing brand green
        brand: "#819231",

        // accent orange for highlights, lines, buttons
        "accent": {
          "orange": "#FF7A18",
          "orange-dark": "#E65A00"
        },

        // warm neutral gray scale (compatible with Tailwind naming but in neutral namespace)
        neutral: {
          50:  "#FAFAFA",
          100: "#F3F4F6",
          200: "#E5E7EB",
          300: "#D1D5DB",
          400: "#9CA3AF",
          500: "#6B7280",
          600: "#4B5563",
          700: "#374151",
          800: "#1F2937"
        }
      },

      // subtle orange shadows for emphasis / elevated buttons/cards
      boxShadow: {
        // soft glow: good for elevated cards
        'orange-soft': '0 10px 30px rgba(255,122,24,0.08)',
        // stronger shadow for important CTAs
        'orange-strong': '0 6px 18px rgba(230,90,0,0.12)'
      },

      // ring colors convenience
      ringColor: {
        'accent-orange': '#FF7A18'
      },

      // optional: custom border radius if you like a softer look (adjust or remove)
      borderRadius: {
        'xl': '1rem'
      }
    }
  },
  plugins: []
}
