# ReStyler Interior AI

## Table of Contents
1.  [Project Description](#project-description)
2.  [Tech Stack](#tech-stack)
3.  [Getting Started Locally](#getting-started-locally)
4.  [Available Scripts](#available-scripts)
5.  [Project Scope](#project-scope)
6.  [Project Status](#project-status)
7.  [License](#license)

## Project Description
ReStyler Interior AI is a web application designed to help users visualize their home interiors (such as bedrooms, kitchens, living rooms) in different styles, color schemes, or arrangements quickly and easily. Users upload a photograph of their room, which serves as a reference and inspiration. Based on a textual description (prompt) provided by the user, the application utilizes the DALL-E 3 model to generate a new vision of that interior.

The primary goal is to provide a tool for users to experiment with design concepts without incurring the physical costs and effort associated with actual renovations or redecorations. It addresses the common difficulty users face in visualizing how their current spaces might look after stylistic, color, or layout changes, thereby reducing the risk of costly design decisions that may not yield the desired results.

## Tech Stack
The project leverages a modern technology stack to deliver a seamless and responsive user experience:

*   **Frontend & Backend Framework:**
    *   **Next.js 15:** A React framework for building fast, interactive user interfaces with excellent support for Server-Side Rendering (SSR) and Static Site Generation (SSG), ensuring dynamic application behavior and SEO optimization.
*   **Styling:**
    *   **Tailwind CSS:** A utility-first CSS framework that significantly speeds up the creation of responsive and fully customizable UI components.
    *   **Shadcn/ui:** Used for UI components, complementing Tailwind CSS.
*   **Backend-as-a-Service (BaaS):**
    *   **Supabase:** An open-source Firebase alternative providing:
        *   Scalable PostgreSQL database.
        *   User authentication (email/password).
        *   File storage (for user photos and AI-generated images).
        *   Auto-generated APIs.
*   **AI Model:**
    *   **DALL-E 3:** Used for generating interior visualizations based on user photos and text prompts.
*   **Deployment & Hosting:**
    *   **Vercel:** The ideal platform for hosting Next.js applications, offering seamless CI/CD, a global CDN for fast content delivery, automatic scaling, and optimizations.

## Getting Started Locally

### Prerequisites
*   **Node.js:** Ensure you have Node.js installed. The required version is specified in the `.nvmrc` file. You can use a Node version manager like `nvm` to switch to the correct version (`nvm use`).
*   **Package Manager:** `npm` or `yarn` (this guide will use `npm` examples).
*   **Supabase Account & Project:**
    *   Create an account at [Supabase.io](https://supabase.io).
    *   Set up a new project and obtain your Project URL and `anon` key.
*   **OpenAI API Key:**
    *   Obtain an API key from [OpenAI](https://platform.openai.com/signup) with access to the DALL-E 3 model.

### Installation & Setup
1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd <repository-name>
    ```
2.  **Install dependencies:**
    ```bash
    npm install
    ```
3.  **Set up environment variables:**
    Create a `.env.local` file in the root of the project by copying the example file (if one exists, e.g., `.env.example`):
    ```bash
    cp .env.example .env.local
    ```
    Add the following environment variables to your `.env.local` file:
    ```env
    NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
    NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
    OPENAI_API_KEY=your_openai_api_key
    # Add any other necessary environment variables
    ```
4.  **Database Migrations (if applicable):**
    If your Supabase project requires initial schema setup or migrations, run the necessary SQL scripts via the Supabase dashboard or CLI.

5.  **Run the development server:**
    ```bash
    npm run dev
    ```
    The application should now be running on `http://localhost:3000`.

## Available Scripts
The following scripts are available in the `package.json`:

*   `npm run dev`: Starts the application in development mode.
*   `npm run build`: Builds the application for production.
*   `npm run start`: Starts the production server (after building).
*   `npm run lint`: Lints the codebase to check for code style issues.

## Project Scope

### In Scope (MVP Features)
The Minimum Viable Product (MVP) focuses on the core functionalities:
*   **User Authentication:**
    *   New user registration with email and password.
    *   Login for existing users.
*   **Image Generation:**
    *   Upload user's interior photo (PNG, JPG, WebP formats accepted).
    *   Input a textual prompt describing desired changes (style, colors, key elements).
    *   Generation of a new interior visualization using DALL-E 3.
    *   Display of the single generated image to the user.
    *   A 10-second timeout for image generation, with an error message on failure.
*   **Generation History:**
    *   Logged-in users can access their history of generated images.
    *   Each history entry includes the reference photo, prompt used, and the generated image.
    *   Ability for users to delete entries from their generation history.
*   **Usage Limits:**
    *   Each registered user is limited to 3 image generations per day.
    *   Users are informed when they reach their daily limit.

### Out of Scope (Future Considerations)
The following features are not part of the MVP but may be considered for future iterations:
*   Advanced input image editing tools (cropping, color correction).
*   Automatic prompt suggestions based on image analysis.
*   Predefined style templates or color palettes.
*   Social features (sharing, commenting, liking).
*   Generating multiple image variations or iterating on previous generations.
*   Payment systems for additional generations or premium features.
*   Native mobile applications (iOS/Android).

## Project Status
This project is currently in the **Minimum Viable Product (MVP) development phase**. The primary focus is on implementing and refining the core functionalities outlined in the project scope to deliver a stable and useful initial product.

## License
This project is licensed under the MIT License. See the `LICENSE` file for more details. 