// src/components/Reports/ReportForm.tsx
import React, { useState } from 'react';
import {
  Container,
  Paper,
  TextField,
  Button,
  Typography,
  Box,
  Alert,
  Chip,
  IconButton,
  AppBar,
  Toolbar
} from '@mui/material';
import { Add, Delete, ArrowBack } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { reportsAPI } from '../../services/api';

const ReportForm: React.FC = () => {
  const navigate = useNavigate();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [links, setLinks] = useState<string[]>(['']);
  const [evidence, setEvidence] = useState('');
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');

  const handleAddLink = () => {
    setLinks([...links, '']);
  };

  const handleLinkChange = (index: number, value: string) => {
    const newLinks = [...links];
    newLinks[index] = value;
    setLinks(newLinks);
  };

  const handleRemoveLink = (index: number) => {
    const newLinks = links.filter((_, i) => i !== index);
    setLinks(newLinks);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const filteredLinks = links.filter(link => link.trim() !== '');
      
      await reportsAPI.submit({
        title,
        description,
        links: filteredLinks.length > 0 ? filteredLinks : undefined,
        evidence: evidence || undefined
      });

      setSuccess(true);
      // Reset form
      setTitle('');
      setDescription('');
      setLinks(['']);
      setEvidence('');
      
      setTimeout(() => {
        navigate('/dashboard');
      }, 2000);
    } catch (err) {
      setError('Failed to submit report. Please try again.');
    } finally {
      setLoading(false);
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
            Submit Threat Report
          </Typography>
        </Toolbar>
      </AppBar>

      <Container maxWidth="md" sx={{ mt: 4 }}>
        <Paper elevation={3} sx={{ p: 4 }}>
          <Typography variant="h4" gutterBottom>
            Report a Cyber Threat
          </Typography>
          <Typography variant="subtitle1" color="textSecondary" gutterBottom sx={{ mb: 3 }}>
            Help protect the community by reporting suspicious activities, malicious URLs, or security threats.
          </Typography>

          {success && (
            <Alert severity="success" sx={{ mb: 3 }}>
              Report submitted successfully! Redirecting to dashboard...
            </Alert>
          )}

          {error && (
            <Alert severity="error" sx={{ mb: 3 }}>
              {error}
            </Alert>
          )}

          <Box component="form" onSubmit={handleSubmit}>
            <TextField
              fullWidth
              label="Threat Title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
              margin="normal"
              helperText="Provide a clear, descriptive title for the threat"
            />

            <TextField
              fullWidth
              label="Description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              required
              multiline
              rows={4}
              margin="normal"
              helperText="Describe the threat in detail - what you observed, how you discovered it, potential impact"
            />

            <Box sx={{ mt: 3, mb: 2 }}>
              <Typography variant="h6" gutterBottom>
                Suspicious URLs/Links (Optional)
              </Typography>
              {links.map((link, index) => (
                <Box key={index} sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                  <TextField
                    fullWidth
                    label={`URL ${index + 1}`}
                    value={link}
                    onChange={(e) => handleLinkChange(index, e.target.value)}
                    margin="normal"
                    placeholder="https://example-malicious-site.com"
                  />
                  {links.length > 1 && (
                    <IconButton
                      color="error"
                      onClick={() => handleRemoveLink(index)}
                      sx={{ ml: 1 }}
                    >
                      <Delete />
                    </IconButton>
                  )}
                </Box>
              ))}
              <Button
                startIcon={<Add />}
                onClick={handleAddLink}
                variant="outlined"
                size="small"
                sx={{ mt: 1 }}
              >
                Add Another URL
              </Button>
            </Box>

            <TextField
              fullWidth
              label="Evidence (Optional)"
              value={evidence}
              onChange={(e) => setEvidence(e.target.value)}
              multiline
              rows={3}
              margin="normal"
              helperText="Any additional evidence like error messages, screenshots (as text), or other relevant information"
            />

            <Box sx={{ mt: 4, display: 'flex', gap: 2 }}>
              <Button
                type="submit"
                variant="contained"
                disabled={loading}
                size="large"
              >
                {loading ? 'Submitting...' : 'Submit Report'}
              </Button>
              <Button
                variant="outlined"
                onClick={() => navigate('/dashboard')}
                size="large"
              >
                Cancel
              </Button>
            </Box>
          </Box>

          <Box sx={{ mt: 4, p: 2, bgcolor: 'grey.50', borderRadius: 1 }}>
            <Typography variant="h6" gutterBottom>
              What happens next?
            </Typography>
            <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
              <Chip label="1. Automatic validation" color="primary" variant="outlined" />
              <Chip label="2. VirusTotal scan" color="primary" variant="outlined" />
              <Chip label="3. Admin review" color="primary" variant="outlined" />
              <Chip label="4. Community notification" color="primary" variant="outlined" />
            </Box>
          </Box>
        </Paper>
      </Container>
    </Box>
  );
};

export default ReportForm;