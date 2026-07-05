import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { useState, useEffect } from "react";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import Users from "./pages/Users";
import MasterData from "./pages/MasterData";
import AuditLog from "./pages/AuditLog";

export default function App() {
  const [isLogin, setIsLogin] = useState(false);

  useEffect(() => {
    const loginStatus = localStorage.getItem("login") === "true";
    setIsLogin(loginStatus);
  }, []);

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login setIsLogin={setIsLogin} />} />

        <Route
          path="/dashboard"
          element={
            isLogin ? (
              <Dashboard setIsLogin={setIsLogin} />
            ) : (
              <Navigate to="/" />
            )
          }
        >
          <Route path="users" element={<Users />} />
          <Route path="master-data" element={<MasterData />} />
          <Route path="audit-log" element={<AuditLog />} />
        </Route>

        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  );
}
