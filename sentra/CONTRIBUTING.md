# Contributing to Sentra

Thank you for your interest in contributing to Sentra! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Getting Started

1. **Fork the Repository**
   ```bash
   # Fork the repo on GitHub, then clone your fork
   git clone https://github.com/your-username/sentra.git
   cd sentra
   ```

2. **Set Up Development Environment**
   ```bash
   # Run the setup script
   ./scripts/setup.sh
   
   # Configure your environment
   cp backend/resources/Config.toml backend/resources/Config-local.toml
   # Update Config-local.toml with your settings
   ```

3. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

### Development Workflow

1. **Make Changes**
   - Follow the coding standards outlined below
   - Write tests for new functionality
   - Update documentation as needed

2. **Test Your Changes**
   ```bash
   # Test backend
   cd backend && bal test
   
   # Test frontend
   cd frontend && npm test
   
   # Test API endpoints
   ./scripts/test-api.sh
   ```

3. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add new threat detection algorithm"
   ```

4. **Push and Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   # Create PR on GitHub
   ```

## 📋 Contribution Guidelines

### Code Style

#### Backend (Ballerina)
- Follow [Ballerina coding conventions](https://ballerina.io/learn/style-guide/)
- Use meaningful variable and function names
- Add documentation comments for public functions
- Handle errors appropriately

```ballerina
// Good example
public isolated function validateEmail(string email) returns boolean {
    // Validate email format using regex
    return email.matches(re `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`);
}
```

#### Frontend (React/TypeScript)
- Use TypeScript for type safety
- Follow React best practices and hooks patterns
- Use Material-UI components consistently
- Implement proper error handling

```typescript
// Good example
interface UserProfileProps {
  user: User;
  onUpdate: (user: User) => void;
}

const UserProfile: React.FC<UserProfileProps> = ({ user, onUpdate }) => {
  // Component implementation
};
```

### Security Guidelines

1. **Never commit sensitive data**
   - API keys, passwords, or secrets
   - Use environment variables or config files (gitignored)

2. **Input validation**
   - Validate all user inputs on both frontend and backend
   - Use parameterized queries for database operations

3. **Authentication**
   - Follow JWT best practices
   - Implement proper session management

### Testing Requirements

#### Backend Testing
```ballerina
@test:Config {}
function testEmailValidation() {
    test:assertTrue(validateEmail("test@example.com"));
    test:assertFalse(validateEmail("invalid-email"));
}
```

#### Frontend Testing
```typescript
describe('UserProfile Component', () => {
  it('should render user information correctly', () => {
    // Test implementation
  });
});
```

### Documentation Standards

1. **Code Documentation**
   - Document all public APIs
   - Include usage examples
   - Explain complex algorithms

2. **README Updates**
   - Update README.md for new features
   - Include configuration instructions
   - Add troubleshooting information

## 🐛 Bug Reports

When reporting bugs, please include:

1. **Environment Information**
   - Operating system
   - Node.js version
   - Ballerina version
   - MySQL version

2. **Steps to Reproduce**
   - Clear, numbered steps
   - Expected vs actual behavior
   - Screenshots if applicable

3. **Error Messages**
   - Full error messages and stack traces
   - Relevant log entries

## 💡 Feature Requests

For new features:

1. **Check existing issues** to avoid duplicates
2. **Describe the use case** and problem being solved
3. **Propose a solution** if you have one in mind
4. **Consider backwards compatibility**

## 📝 Commit Message Format

Use conventional commits format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(auth): add two-factor authentication
fix(api): resolve JWT token expiration issue
docs(readme): update installation instructions
```

## 🔄 Release Process

1. **Version Bumping**
   - Follow semantic versioning (SemVer)
   - Update version in package.json and Ballerina.toml

2. **Changelog**
   - Update CHANGELOG.md with new features and fixes
   - Include migration notes if needed

3. **Testing**
   - Run full test suite
   - Test on multiple environments

## 👥 Code Review Process

### For Contributors
1. **Self-review** your code before submitting
2. **Write clear PR descriptions**
3. **Respond to feedback** promptly
4. **Keep PRs focused** on single features/fixes

### For Reviewers
1. **Be constructive** in feedback
2. **Check for security issues**
3. **Verify tests pass**
4. **Consider backwards compatibility**

## 🛡️ Security Considerations

### Responsible Disclosure
If you find security vulnerabilities:

1. **Do NOT** create public issues
2. **Email** security@sentra-project.com
3. **Provide** detailed information
4. **Allow time** for patching before disclosure

### Security Checklist
- [ ] No hardcoded secrets
- [ ] Input validation implemented
- [ ] SQL injection prevention
- [ ] XSS protection
- [ ] Authentication checks
- [ ] Authorization verification

## 📞 Getting Help

### Community
- **GitHub Discussions**: For questions and ideas
- **GitHub Issues**: For bugs and feature requests
- **Email**: contribute@sentra-project.com

### Resources
- [Ballerina Documentation](https://ballerina.io/learn/)
- [React Documentation](https://reactjs.org/docs/)
- [Material-UI Documentation](https://mui.com/)
- [MySQL Documentation](https://dev.mysql.com/doc/)

## 🏆 Recognition

Contributors are recognized in:
- README.md contributors section
- Release notes
- Project documentation

## 📄 License

By contributing to Sentra, you agree that your contributions will be licensed under the [MIT License](LICENSE).

---

Thank you for contributing to Sentra! Together, we're building a safer digital world. 🛡️