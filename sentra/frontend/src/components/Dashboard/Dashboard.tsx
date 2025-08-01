// src/components/Dashboard/Dashboard.tsx
import React, { useState, useEffect } from 'react';
import {
  AppBar,
  Toolbar,
  Typography,
  Container,
  Grid,
  Paper,
  Card,
  CardContent,
  Button,
  Box,
  IconButton,
  Badge,
  Menu,
  MenuItem,
  Chip,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  Drawer,
  Divider
} from '@mui/material';
import {
  Security,
  Report,
  Notifications,
  AccountCircle,
  Menu as MenuIcon,
  Warning,
  CheckCircle,
  Pending,
  Add,
  Assessment,
  AdminPanelSettings
} from '@mui/icons-material';
import { useAuth } from '../../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import { notificationsAPI, reportsAPI, breachAPI } from '../../services/api';

const Dashboard: React.FC = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [notifications, setNotifications] = useState<any[]>([]);
  const [reports, setReports] = useState<any[]>([]);
  const [breachLogs, setBreachLogs] = useState<any[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      const [notifResponse, reportsResponse, breachResponse, unreadResponse] = await Promise.all([
        notificationsAPI.getAll(),
        reportsAPI.getAll(),
        breachAPI.getLogs(),
        notificationsAPI.getUnreadCount()
      ]);

      setNotifications(notifResponse.data.slice(0, 5)); // Show latest 5
      setReports(reportsResponse.data.slice(0, 5)); // Show latest 5
      setBreachLogs(breachResponse.data);
      setUnreadCount(unreadResponse.data.count);
    } catch (error) {
      console.error('Failed to load dashboard data:', error);
    }
  };

  const handleMenu = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Validated': return 'success';
      case 'Pending': return 'warning';
      case 'False_Alarm': return 'default';
      case 'Escalated': return 'error';
      default: return 'default';
    }
  };

  const drawerItems = [
    { text: 'Dashboard', icon: <Assessment />, path: '/dashboard' },
    { text: 'Submit Report', icon: <Add />, path: '/report' },
    { text: 'Admin Panel', icon: <AdminPanelSettings />, path: '/admin' },
  ];

  return (
    <Box sx={{ flexGrow: 1 }}>
      <AppBar position="static">
        <Toolbar>
          <IconButton
            size="large"
            edge="start"
            color="inherit"
            aria-label="menu"
            sx={{ mr: 2 }}
            onClick={() => setDrawerOpen(true)}
          >
            <MenuIcon />
          </IconButton>
          <Security sx={{ mr: 2 }} />
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Sentra - Threat Monitoring
          </Typography>
          <IconButton color="inherit" onClick={() => navigate('/notifications')}>
            <Badge badgeContent={unreadCount} color="error">
              <Notifications />
            </Badge>
          </IconButton>
          <IconButton
            size="large"
            aria-label="account of current user"
            aria-controls="menu-appbar"
            aria-haspopup="true"
            onClick={handleMenu}
            color="inherit"
          >
            <AccountCircle />
          </IconButton>
          <Menu
            id="menu-appbar"
            anchorEl={anchorEl}
            anchorOrigin={{
              vertical: 'top',
              horizontal: 'right',
            }}
            keepMounted
            transformOrigin={{
              vertical: 'top',
              horizontal: 'right',
            }}
            open={Boolean(anchorEl)}
            onClose={handleClose}
          >
            <MenuItem onClick={handleClose}>Profile</MenuItem>
            <MenuItem onClick={handleLogout}>Logout</MenuItem>
          </Menu>
        </Toolbar>
      </AppBar>

      <Drawer anchor="left" open={drawerOpen} onClose={() => setDrawerOpen(false)}>
        <Box sx={{ width: 250 }} role="presentation">
          <Typography variant="h6" sx={{ p: 2 }}>
            Navigation
          </Typography>
          <Divider />
          <List>
            {drawerItems.map((item) => (
              <ListItem button key={item.text} onClick={() => {
                navigate(item.path);
                setDrawerOpen(false);
              }}>
                <ListItemIcon>{item.icon}</ListItemIcon>
                <ListItemText primary={item.text} />
              </ListItem>
            ))}
          </List>
        </Box>
      </Drawer>

      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <Typography variant="h4" gutterBottom>
          Welcome back, {user?.name}!
        </Typography>
        
        <Grid container spacing={3}>
          {/* Stats Cards */}
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography color="textSecondary" gutterBottom>
                  Total Reports
                </Typography>
                <Typography variant="h4">
                  {reports.length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography color="textSecondary" gutterBottom>
                  Breach Scans
                </Typography>
                <Typography variant="h4">
                  {breachLogs.length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography color="textSecondary" gutterBottom>
                  Notifications
                </Typography>
                <Typography variant="h4">
                  {unreadCount}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography color="textSecondary" gutterBottom>
                  Account Status
                </Typography>
                <Chip label="Active" color="success" />
              </CardContent>
            </Card>
          </Grid>

          {/* Recent Reports */}
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 2 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Typography variant="h6">Recent Reports</Typography>
                <Button variant="outlined" size="small" onClick={() => navigate('/report')}>
                  Submit New
                </Button>
              </Box>
              <List>
                {reports.map((report, index) => (
                  <ListItem key={index}>
                    <ListItemIcon>
                      <Report />
                    </ListItemIcon>
                    <ListItemText 
                      primary={report.title}
                      secondary={`Status: ${report.status}`}
                    />
                    <Chip 
                      label={report.status} 
                      color={getStatusColor(report.status)}
                      size="small"
                    />
                  </ListItem>
                ))}
                {reports.length === 0 && (
                  <Typography color="textSecondary" sx={{ textAlign: 'center', py: 2 }}>
                    No reports yet
                  </Typography>
                )}
              </List>
            </Paper>
          </Grid>

          {/* Recent Notifications */}
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 2 }}>
              <Typography variant="h6" gutterBottom>
                Recent Notifications
              </Typography>
              <List>
                {notifications.map((notification, index) => (
                  <ListItem key={index}>
                    <ListItemIcon>
                      {notification.type === 'breach_detected' ? <Warning color="warning" /> : 
                       notification.type === 'report_update' ? <CheckCircle color="success" /> : 
                       <Pending color="info" />}
                    </ListItemIcon>
                    <ListItemText 
                      primary={notification.title}
                      secondary={notification.message}
                    />
                  </ListItem>
                ))}
                {notifications.length === 0 && (
                  <Typography color="textSecondary" sx={{ textAlign: 'center', py: 2 }}>
                    No notifications
                  </Typography>
                )}
              </List>
            </Paper>
          </Grid>

          {/* Quick Actions */}
          <Grid item xs={12}>
            <Paper sx={{ p: 2 }}>
              <Typography variant="h6" gutterBottom>
                Quick Actions
              </Typography>
              <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                <Button 
                  variant="contained" 
                  startIcon={<Add />}
                  onClick={() => navigate('/report')}
                >
                  Submit Threat Report
                </Button>
                <Button 
                  variant="outlined" 
                  startIcon={<Security />}
                  onClick={() => breachAPI.initiateScan()}
                >
                  Run Breach Scan
                </Button>
                <Button 
                  variant="outlined" 
                  startIcon={<Assessment />}
                  onClick={() => navigate('/admin')}
                >
                  Admin Dashboard
                </Button>
              </Box>
            </Paper>
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
};

export default Dashboard;