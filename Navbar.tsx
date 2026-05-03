// ============================================
// NovaDrop - Navbar Component
// ============================================
import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Search,
  ShoppingCart,
  Heart,
  User,
  Menu,
  X,
  ChevronDown,
  LogOut,
  Package,
  Settings
} from 'lucide-react';
import { useAuth } from './src/context/AuthContext';
import { useCart } from './src/context/CartContext';
import { useWishlist } from './src/context/WishlistContext';
import { categories } from './src/data/products';
export function Navbar() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const location = useLocation();
  const { isAuthenticated, user, logout } = useAuth();
  const { itemCount } = useCart();
  const { items: wishlistItems } = useWishlist();
  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      window.location.href = `/products?search=${encodeURIComponent(searchQuery)}`;
    }
  };
  const navLinks = [
    { name: 'Home', path: '/' },
    { name: 'Products', path: '/products' },
    { name: 'Deals', path: '/products?sort=newest' },
    { name: 'About Us', path: '/about' },
    { name: 'Customer Care', path: '/contact' }
  ];
  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-slate-950/95 backdrop-blur-xl border-b border-amber-500/10">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16 lg:h-20">
          <Link to="/" className="flex items-center space-x-2">
             <motion.div whileHover={{ scale: 1.05 }} className="flex items-center">
               <img src="/images/logo.png" alt="NovaDrop Logo" className="h-14 lg:h-16 w-auto object-contain" />
             </motion.div>
          </Link>
          <div className="hidden lg:flex items-center space-x-8">
            {navLinks.map((link) => (
              <Link
                key={link.name}
                to={link.path}
                className={`text-sm font-medium transition-colors relative group ${
                  location.pathname === link.path ? 'text-amber-400' : 'text-slate-300 hover:text-white'
                }`}
              >
                {link.name}
                <span className={`absolute -bottom-1 left-0 h-0.5 bg-amber-400 transition-all ${
                  location.pathname === link.path ? 'w-full' : 'w-0 group-hover:w-full'
                }`} />
              </Link>
            ))}
            <div className="relative group">
              <button className="flex items-center space-x-1 text-sm font-medium text-slate-300 hover:text-white transition-colors">
                <span>Categories</span>
                <ChevronDown className="w-4 h-4 transition-transform group-hover:rotate-180" />
              </button>
              <div className="absolute top-full left-0 pt-2 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all">
                <div className="bg-slate-900 border border-amber-500/20 rounded-xl py-2 min-w-[200px] shadow-2xl">
                  {categories.slice(1).map((category) => (
                    <Link
                      key={category}
                      to={`/products?category=${encodeURIComponent(category)}`}
                      className="block px-4 py-2 text-sm text-slate-300 hover:text-amber-400 hover:bg-slate-800 transition-colors"
                    >
                      {category}
                    </Link>
                  ))}
                </div>
              </div>
            </div>
          </div>
          <AnimatePresence>
            {isSearchOpen && (
              <motion.form
                initial={{ opacity: 0, width: 0 }}
                animate={{ opacity: 1, width: 'auto' }}
                exit={{ opacity: 0, width: 0 }}
                onSubmit={handleSearch}
                className="hidden md:flex items-center"
              >
                <div className="relative">
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder="Search products..."
                    className="w-64 px-4 py-2 pl-10 bg-slate-800 border border-slate-700 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:border-amber-500 transition-colors"
                    autoFocus
                  />
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                </div>
              </motion.form>
            )}
          </AnimatePresence>
          <div className="flex items-center space-x-4">
            <button
              onClick={() => setIsSearchOpen(!isSearchOpen)}
              className="p-2 text-slate-300 hover:text-white transition-colors md:block hidden"
            >
              {isSearchOpen ? <X className="w-5 h-5" /> : <Search className="w-5 h-5" />}
            </button>
            <Link to="/wishlist" className="p-2 text-slate-300 hover:text-white transition-colors relative">
              <Heart className="w-5 h-5" />
              {wishlistItems.length > 0 && (
                <span className="absolute -top-1 -right-1 w-5 h-5 bg-amber-500 text-slate-950 text-xs font-bold rounded-full flex items-center justify-center">
                  {wishlistItems.length}
                </span>
              )}
            </Link>
            <Link to="/cart" className="p-2 text-slate-300 hover:text-white transition-colors relative">
              <ShoppingCart className="w-5 h-5" />
              {itemCount > 0 && (
                <span className="absolute -top-1 -right-1 w-5 h-5 bg-amber-500 text-slate-950 text-xs font-bold rounded-full flex items-center justify-center">
                  {itemCount}
                </span>
              )}
            </Link>
            {isAuthenticated ? (
              <div className="relative">
                <button
                  onClick={() => setIsProfileOpen(!isProfileOpen)}
                  className="flex items-center space-x-2 p-2 text-slate-300 hover:text-white transition-colors"
                >
                  <div className="w-8 h-8 rounded-full bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center">
                    <span className="text-slate-950 font-semibold text-sm">
                      {user?.name?.charAt(0).toUpperCase()}
                    </span>
                  </div>
                </button>
                <AnimatePresence>
                  {isProfileOpen && (
                    <motion.div
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: 10 }}
                      className="absolute top-full right-0 pt-2"
                    >
                      <div className="bg-slate-900 border border-amber-500/20 rounded-xl py-2 min-w-[200px] shadow-2xl">
                        <div className="px-4 py-2 border-b border-slate-700">
                          <p className="text-white font-medium">{user?.name}</p>
                          <p className="text-slate-400 text-sm">{user?.email}</p>
                        </div>
                        <Link
                          to="/profile"
                          onClick={() => setIsProfileOpen(false)}
                          className="flex items-center space-x-2 px-4 py-2 text-sm text-slate-300 hover:text-amber-400 hover:bg-slate-800 transition-colors"
                        >
                          <User className="w-4 h-4" />
                          <span>Profile</span>
                        </Link>
                        <Link
                          to="/orders"
                          onClick={() => setIsProfileOpen(false)}
                          className="flex items-center space-x-2 px-4 py-2 text-sm text-slate-300 hover:text-amber-400 hover:bg-slate-800 transition-colors"
                        >
                          <Package className="w-4 h-4" />
                          <span>My Orders</span>
                        </Link>
                        <Link
                          to="/settings"
                          onClick={() => setIsProfileOpen(false)}
                          className="flex items-center space-x-2 px-4 py-2 text-sm text-slate-300 hover:text-amber-400 hover:bg-slate-800 transition-colors"
                        >
                          <Settings className="w-4 h-4" />
                          <span>Settings</span>
                        </Link>
                        <button
                          onClick={() => {
                            logout();
                            setIsProfileOpen(false);
                          }}
                          className="flex items-center space-x-2 px-4 py-2 text-sm text-red-400 hover:text-red-300 hover:bg-slate-800 transition-colors w-full"
                        >
                          <LogOut className="w-4 h-4" />
                          <span>Logout</span>
                        </button>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            ) : (
              <Link
                to="/login"
                className="hidden sm:flex items-center space-x-2 px-4 py-2 bg-gradient-to-r from-amber-500 to-amber-600 text-slate-950 font-medium rounded-lg hover:from-amber-400 hover:to-amber-500 transition-all"
              >
                <User className="w-4 h-4" />
                <span>Login</span>
              </Link>
            )}
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="lg:hidden p-2 text-slate-300 hover:text-white transition-colors"
            >
              {isMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>
      </div>
      <AnimatePresence>
        {isMenuOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="lg:hidden bg-slate-900 border-t border-amber-500/10"
          >
            <div className="px-4 py-4 space-y-4">
              <form onSubmit={handleSearch} className="relative">
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search products..."
                  className="w-full px-4 py-2 pl-10 bg-slate-800 border border-slate-700 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:border-amber-500"
                />
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
              </form>
              {navLinks.map((link) => (
                <Link
                  key={link.name}
                  to={link.path}
                  onClick={() => setIsMenuOpen(false)}
                  className={`block py-2 font-medium transition-colors ${
                    location.pathname === link.path ? 'text-amber-400' : 'text-slate-300'
                  }`}
                >
                  {link.name}
                </Link>
              ))}
              <div className="pt-2 border-t border-slate-700">
                <p className="text-slate-400 text-sm mb-2">Categories</p>
                {categories.slice(1).map((category) => (
                  <Link
                    key={category}
                    to={`/products?category=${encodeURIComponent(category)}`}
                    onClick={() => setIsMenuOpen(false)}
                    className="block py-2 text-slate-300 hover:text-amber-400 transition-colors"
                  >
                    {category}
                  </Link>
                ))}
              </div>
              {!isAuthenticated && (
                <Link
                  to="/login"
                  onClick={() => setIsMenuOpen(false)}
                  className="block w-full text-center py-3 bg-gradient-to-r from-amber-500 to-amber-600 text-slate-950 font-medium rounded-lg"
                >
                  Login / Register
                </Link>
              )}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </nav>
  );
}
