// src/components/Admin/AdminDashboard.tsx
import React, { useState, useEffect } from 'react';
import {
  Container,
  Paper,
  Typography,
  Box,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  AppBar,
  Toolbar,
  IconButton,
  Alert
} from '@mui/material';
import { ArrowBack, Visibility } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { adminAPI, ThreatReport } from '../../services/api';

const AdminDashboard: React.FC = () => {
  const navigate = useNavigate();
  const [reports, setReports] = useState<ThreatReport[]>([]);
  const [selectedReport, setSelectedReport] = useState<ThreatReport | null>(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [validationStatus, setValidationStatus] = useState('');
  const [remarks, setRemarks] = useState('');
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState('');

  useEffect(() => {
    loadReports();
  }, []);

  const loadReports = async () => {
    try {
      const response = await adminAPI.getReports();
      setReports(response.data);
    } catch (error) {
      console.error('Failed to load reports:', error);
    }
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

  const handleViewReport = (report: ThreatReport) => {
    setSelectedReport(report);
    setValidationStatus(report.status);
    setRemarks(report.admin_remarks || '');
    setDialogOpen(true);
  };

  const handleValidateReport = async () => {
    if (!selectedReport) return;

    setLoading(true);
    try {
      await adminAPI.validateReport(selectedReport.id, validationStatus, remarks);
      setSuccess('Report validated successfully!');
      setDialogOpen(false);
      loadReports(); // Reload reports
      
      setTimeout(() => setSuccess(''), 3000);
    } catch (error) {
      console.error('Failed to validate report:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString() + ' ' + new Date(dateString).toLocaleTimeString();
  };

  const parseLinks = (links: any) => {
    try {
      return Array.isArray(links) ? links : JSON.parse(links || '[]');
    } catch {
      return [];
    }
  };

  return (
    <Box>
      <AppBar position="static">
        <Toolbar>
          <IconButton
            edge="start"
            color="inherit"
            onClick={() => navigate('/dashboard')}
            sx={{ mr: 2 }}
          >
            <ArrowBack />
          </IconButton>
          <Typography variant="h6">
            Admin Dashboard
          </Typography>
        </Toolbar>
      </AppBar>

      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Typography variant="h4" gutterBottom>
          Threat Reports Management
        </Typography>

        {success && (
          <Alert severity="success" sx={{ mb: 3 }}>
            {success}
          </Alert>
        )}

        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Title</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Submitted Date</TableCell>
                <TableCell>VirusTotal Result</TableCell>
                <TableCell>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {reports.map((report) => (
                <TableRow key={report.id}>
                  <TableCell>
                    <Typography variant="subtitle2">{report.title}</Typography>
                    <Typography variant="body2" color="textSecondary">
                      {report.description.substring(0, 100)}...
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Chip 
                      label={report.status} 
                      color={getStatusColor(report.status)}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>{formatDate(report.created_at)}</TableCell>
                  <TableCell>
                    {report.virus_total_result ? (
                      <Chip label="Scanned" color="info" size="small" />
                    ) : (
                      <Chip label="Pending" color="default" size="small" />
                    )}
                  </TableCell>
                  <TableCell>
                    <Button
                      startIcon={<Visibility />}
                      onClick={() => handleViewReport(report)}
                      size="small"
                    >
                      Review
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>

        {/* Report Detail Dialog */}
        <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="md" fullWidth>
          <DialogTitle>Report Details</DialogTitle>
          <DialogContent>
            {selectedReport && (
              <Box sx={{ mt: 1 }}>
                <Typography variant="h6" gutterBottom>
                  {selectedReport.title}
                </Typography>
                <Typography variant="body1" paragraph>
                  {selectedReport.description}
                </Typography>

                {parseLinks(selectedReport.links).length > 0 && (
                  <Box sx={{ mb: 2 }}>
                    <Typography variant="subtitle2" gutterBottom>
                      Suspicious URLs:
                    </Typography>
                    {parseLinks(selectedReport.links).map((link: string, index: number) => (
                      <Chip key={index} label={link} variant="outlined" sx={{ m: 0.5 }} />
                    ))}
                  </Box>
                )}

                {selectedReport.evidence && (
                  <Box sx={{ mb: 2 }}>
                    <Typography variant="subtitle2" gutterBottom>
                      Evidence:
                    </Typography>
                    <Typography variant="body2">{selectedReport.evidence}</Typography>
                  </Box>
                )}

                {selectedReport.virus_total_result && (
                  <Box sx={{ mb: 2 }}>
                    <Typography variant="subtitle2" gutterBottom>
                      VirusTotal Results:
                    </Typography>
                    <pre style={{ fontSize: '12px', background: '#f5f5f5', padding: '8px', borderRadius: '4px' }}>
                      {JSON.stringify(selectedReport.virus_total_result, null, 2)}
                    </pre>
                  </Box>
                )}

                <FormControl fullWidth sx={{ mb: 2 }}>
                  <InputLabel>Validation Status</InputLabel>
                  <Select
                    value={validationStatus}
                    onChange={(e) => setValidationStatus(e.target.value)}
                  >
                    <MenuItem value="Pending">Pending</MenuItem>
                    <MenuItem value="Validated">Validated</MenuItem>
                    <MenuItem value="False_Alarm">False Alarm</MenuItem>
                    <MenuItem value="Escalated">Escalated</MenuItem>
                  </Select>
                </FormControl>

                <TextField
                  fullWidth
                  label="Admin Remarks"
                  value={remarks}
                  onChange={(e) => setRemarks(e.target.value)}
                  multiline
                  rows={3}
                  placeholder="Add your validation remarks here..."
                />
              </Box>
            )}
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button 
              onClick={handleValidateReport} 
              variant="contained"
              disabled={loading}
            >
              {loading ? 'Validating...' : 'Validate Report'}
            </Button>
          </DialogActions>
        </Dialog>
      </Container>
    </Box>
  );
};

export default AdminDashboard;