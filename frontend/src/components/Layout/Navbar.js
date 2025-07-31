import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { 
  Bars3Icon, 
  BellIcon, 
  UserCircleIcon,
  ChevronDownIcon,
  ShieldCheckIcon,
  CogIcon,
  ArrowRightOnRectangleIcon
} from '@heroicons/react/24/outline';
import { Menu, Transition } from '@headlessui/react';
import { useAuth } from '../../contexts/AuthContext';
import { notificationAPI } from '../../services/api';

const Navbar = ({ onMenuClick, user }) => {
  const { logout, getBreachStatus } = useAuth();
  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);

  useEffect(() => {
    loadNotifications();
  }, []);

  const loadNotifications = async () => {
    try {
      const response = await notificationAPI.getNotifications();
      if (response.success) {
        setNotifications(response.data);
        setUnreadCount(response.data.filter(n => n.status === 'unseen').length);
      }
    } catch (error) {
      console.error('Failed to load notifications:', error);
    }
  };

  const handleLogout = async () => {
    await logout();
  };

  const breachStatus = getBreachStatus();

  return (
    <div className="sticky top-0 z-30 bg-white shadow-sm border-b border-gray-200">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex h-16 justify-between">
          <div className="flex">
            {/* Mobile menu button */}
            <div className="flex items-center lg:hidden">
              <button
                type="button"
                className="inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-gray-100 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500"
                onClick={onMenuClick}
              >
                <span className="sr-only">Open main menu</span>
                <Bars3Icon className="h-6 w-6" aria-hidden="true" />
              </button>
            </div>

            {/* Logo for mobile */}
            <div className="flex items-center lg:hidden ml-4">
              <ShieldCheckIcon className="h-8 w-8 text-primary-600" />
              <span className="ml-2 text-xl font-bold text-gray-900">CyberCare</span>
            </div>
          </div>

          <div className="flex items-center space-x-4">
            {/* Breach status indicator */}
            {breachStatus.isBreached && (
              <Link
                to="/profile"
                className="flex items-center space-x-2 rounded-md bg-danger-50 px-3 py-1 text-sm text-danger-700 hover:bg-danger-100 transition-colors"
              >
                <ShieldCheckIcon className="h-4 w-4" />
                <span className="font-medium">{breachStatus.count} breach(es) detected</span>
              </Link>
            )}

            {/* Notifications */}
            <Menu as="div" className="relative">
              <Menu.Button className="relative rounded-full bg-white p-1 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2">
                <span className="sr-only">View notifications</span>
                <BellIcon className="h-6 w-6" aria-hidden="true" />
                {unreadCount > 0 && (
                  <span className="absolute -top-1 -right-1 h-4 w-4 rounded-full bg-danger-500 text-xs text-white flex items-center justify-center">
                    {unreadCount > 9 ? '9+' : unreadCount}
                  </span>
                )}
              </Menu.Button>
              <Transition
                enter="transition ease-out duration-100"
                enterFrom="transform opacity-0 scale-95"
                enterTo="transform opacity-100 scale-100"
                leave="transition ease-in duration-75"
                leaveFrom="transform opacity-100 scale-100"
                leaveTo="transform opacity-0 scale-95"
              >
                <Menu.Items className="absolute right-0 z-10 mt-2 w-80 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
                  <div className="px-4 py-2 border-b border-gray-200">
                    <h3 className="text-sm font-medium text-gray-900">Notifications</h3>
                  </div>
                  <div className="max-h-64 overflow-y-auto">
                    {notifications.length > 0 ? (
                      notifications.slice(0, 5).map((notification) => (
                        <Menu.Item key={notification.id}>
                          {({ active }) => (
                            <div
                              className={`${
                                active ? 'bg-gray-50' : ''
                              } px-4 py-3 text-sm border-b border-gray-100 last:border-b-0`}
                            >
                              <div className="flex items-start space-x-3">
                                <div className={`w-2 h-2 rounded-full mt-2 ${
                                  notification.status === 'unseen' ? 'bg-primary-500' : 'bg-gray-300'
                                }`} />
                                <div className="flex-1">
                                  <p className="font-medium text-gray-900">{notification.title}</p>
                                  <p className="text-gray-600">{notification.message}</p>
                                  <p className="text-xs text-gray-400 mt-1">
                                    {new Date(notification.createdAt).toLocaleDateString()}
                                  </p>
                                </div>
                              </div>
                            </div>
                          )}
                        </Menu.Item>
                      ))
                    ) : (
                      <div className="px-4 py-6 text-sm text-gray-500 text-center">
                        No notifications
                      </div>
                    )}
                  </div>
                  {notifications.length > 5 && (
                    <div className="px-4 py-2 border-t border-gray-200">
                      <Link
                        to="/notifications"
                        className="text-sm text-primary-600 hover:text-primary-500"
                      >
                        View all notifications
                      </Link>
                    </div>
                  )}
                </Menu.Items>
              </Transition>
            </Menu>

            {/* User menu */}
            <Menu as="div" className="relative">
              <Menu.Button className="flex items-center space-x-2 rounded-full bg-white text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2">
                <span className="sr-only">Open user menu</span>
                {user?.avatar ? (
                  <img
                    className="h-8 w-8 rounded-full"
                    src={user.avatar}
                    alt={user.name}
                  />
                ) : (
                  <UserCircleIcon className="h-8 w-8 text-gray-400" />
                )}
                <span className="hidden md:block text-sm font-medium text-gray-700">
                  {user?.name}
                </span>
                <ChevronDownIcon className="h-4 w-4 text-gray-400" />
              </Menu.Button>
              <Transition
                enter="transition ease-out duration-100"
                enterFrom="transform opacity-0 scale-95"
                enterTo="transform opacity-100 scale-100"
                leave="transition ease-in duration-75"
                leaveFrom="transform opacity-100 scale-100"
                leaveTo="transform opacity-0 scale-95"
              >
                <Menu.Items className="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
                  <Menu.Item>
                    {({ active }) => (
                      <Link
                        to="/profile"
                        className={`${
                          active ? 'bg-gray-100' : ''
                        } flex items-center px-4 py-2 text-sm text-gray-700`}
                      >
                        <UserCircleIcon className="mr-3 h-4 w-4" />
                        Profile
                      </Link>
                    )}
                  </Menu.Item>
                  <Menu.Item>
                    {({ active }) => (
                      <Link
                        to="/settings"
                        className={`${
                          active ? 'bg-gray-100' : ''
                        } flex items-center px-4 py-2 text-sm text-gray-700`}
                      >
                        <CogIcon className="mr-3 h-4 w-4" />
                        Settings
                      </Link>
                    )}
                  </Menu.Item>
                  <Menu.Item>
                    {({ active }) => (
                      <button
                        onClick={handleLogout}
                        className={`${
                          active ? 'bg-gray-100' : ''
                        } flex w-full items-center px-4 py-2 text-sm text-gray-700`}
                      >
                        <ArrowRightOnRectangleIcon className="mr-3 h-4 w-4" />
                        Sign out
                      </button>
                    )}
                  </Menu.Item>
                </Menu.Items>
              </Transition>
            </Menu>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Navbar;