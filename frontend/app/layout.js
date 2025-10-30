import "./globals.css";
import ClientLayout from "@/components/ClientLayout";

export const metadata = {
  title: "E-Commerce MVP - Shop Amazing Products",
  description:
    "Full-stack e-commerce platform with Next.js 15 and Django 5",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="bg-white min-h-screen">
        <ClientLayout children={children} />
      </body>
    </html>
  );
}
