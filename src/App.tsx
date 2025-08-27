import React, { Suspense } from "react";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { Toaster } from "@/components/ui/sonner";
import { AuthProvider } from "@/hooks/useAuth";
import ProtectedRoute from "@/components/ProtectedRoute";
import Layout from "./components/Layout";
import Index from "./pages/Index";
import Stocks from "./pages/Stocks";
import ProductDetail from "./pages/ProductDetail";
import AddProduct from "./pages/AddProduct";
import Facturation from "./pages/Facturation";
import Entreprises from "./pages/Entreprises";
import Equipe from "./pages/Equipe";
import Promotions from "./pages/Promotions";
import Categories from "./pages/Categories";
import Rapports from "./pages/Rapports";
import Clients from "./pages/Clients";
import ClientDetail from "./pages/ClientDetail";
import Vente from "./pages/Vente";
import Parametres from "./pages/Parametres";
import NotFound from "./pages/NotFound";
import Profile from "./pages/Profile";
import Notifications from "./pages/Notifications";
import Auth from "./pages/Auth";
import CompanySetup from "./pages/CompanySetup";
import { PwaInstallPrompt } from "./components/PwaInstallPrompt";

// Lazy load heavy IA page
const AssistantIA = React.lazy(() => import("./pages/AssistantIA"));

const queryClient = new QueryClient();

const App = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <AuthProvider>
          <BrowserRouter>
            <Routes>
              {/* Public routes */}
              <Route path="/auth" element={<Auth />} />

              {/* Company setup - protected but outside main layout */}
              <Route path="/company-setup" element={
                <ProtectedRoute>
                  <CompanySetup />
                </ProtectedRoute>
              } />

              {/* Protected routes with layout */}
              <Route path="/*" element={
                <ProtectedRoute>
                  <Layout>
                    <Routes>
                      <Route path="/" element={<Index />} />
                      <Route path="/stocks" element={<Stocks />} />
                      <Route path="/stocks/:id" element={<ProductDetail />} />
                      <Route path="/stocks/add" element={<AddProduct />} />
                      <Route path="/rapports" element={<Rapports />} />
                      <Route path="/facturation" element={<Facturation />} />
                      <Route path="/entreprises" element={<Entreprises />} />
                      <Route path="/equipe" element={<Equipe />} />
                      <Route path="/promotions" element={<Promotions />} />
                      <Route path="/parametres" element={<Parametres />} />
                      <Route path="/categories" element={<Categories />} />
                      <Route path="/clients" element={<Clients />} />
                      <Route path="/clients/:id" element={<ClientDetail />} />
                      <Route path="/vente" element={<Vente />} />
                      <Route path="/profile" element={<Profile />} />
                      <Route path="/notifications" element={<Notifications />} />
                      <Route path="/assistant" element={
                        <Suspense fallback={
                          <div className="flex items-center justify-center h-screen">
                            <div className="text-center">
                              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
                              <p>Chargement de l'Assistant IA...</p>
                            </div>
                          </div>
                        }>
                          <AssistantIA />
                        </Suspense>
                      } />
                      <Route path="*" element={<NotFound />} />
                    </Routes>
                  </Layout>
                </ProtectedRoute>
              } />
            </Routes>
            <PwaInstallPrompt />
            <Toaster />
          </BrowserRouter>
        </AuthProvider>
      </TooltipProvider>
    </QueryClientProvider>
  );
};

export default App;