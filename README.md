# 📲 SplitMate - Smart Expense Sharing App

![SplitMate Banner](https://imgur.com/5PkHTfN.png)  
*A seamless way to split expenses with friends, roommates, or travel buddies!*

## 🚀 About SplitMate
SplitMate is a modern expense-sharing app that helps users effortlessly split bills, track payments, and settle debts. Whether you're traveling with friends, sharing rent, or splitting a dinner bill, SplitMate ensures fair and transparent expense management.

---

## ✨ Features
✅ **Create and Manage Groups** – Easily create groups and invite friends via a unique code.  
✅ **Track Expenses** – Add expenses, select who paid, and split costs fairly.  
✅ **Smart Balances** – See who owes whom and how much at a glance.  
✅ **Expense Editing** – Modify expenses and keep track of changes.  
✅ **Settle Payments** – Mark debts as settled when payments are made.  
✅ **Secure Authentication** – Secure login with authentication tokens.  
✅ **Multi-Platform** – Available on Android and iOS.  

---

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)  
- **Backend:** Node.js, Express  
- **Database:** MongoDB  
- **State Management:** Provider  
- **Authentication:** JWT  
- **CI/CD:** GitHub Actions  

---

## 📸 Screenshots

| Create Group  | Add Expense | Balances |
|--------------|------------|----------|
| ![Create Group](https://imgur.com/N94HBVl.png) | ![Add Expense](https://imgur.com/1ZFtS8Z.png) | ![Balances](https://imgur.com/91z8ghZ.png) |

---

## 📥 Installation & Setup

### **🔹 Prerequisites**
- Install **Flutter SDK**: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
- Install **Node.js** and **MongoDB** for the backend.

### **🔹 Backend Setup**
1. Clone the backend repository:
   ```bash
   git clone https://github.com/jonasradke-dev/splitmate-backend.git
   cd splitmate-backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up environment variables in `.env`:
   ```
   PORT=3000
   MONGO_URI=mongodb://localhost:27017/splitmate
   JWT_SECRET=your_secret_key
   ```
4. Start the server:
   ```bash
   npm start
   ```

### **🔹 Frontend Setup**
1. Clone the Flutter repository:
   ```bash
   git clone https://github.com/jonasradke-dev/splitmate.git
   cd splitmate
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

---

## 🏗️ Development & Contribution
Want to contribute? Follow these steps:
1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-branch
   ```
3. Make your changes and commit:
   ```bash
   git commit -m "Added new feature"
   ```
4. Push your changes:
   ```bash
   git push origin feature-branch
   ```
5. Create a Pull Request.

---

## 🚀 Deployment
To generate a release build for Android:
```bash
flutter build apk --release
```
For iOS:
```bash
flutter build ios --release --no-codesign
```

---

## 🛠️ API Endpoints (Backend)
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/auth/register` | Register a new user |
| `POST` | `/auth/login` | Login user and get token |
| `POST` | `/groups/create` | Create a new group |
| `POST` | `/groups/join` | Join a group with an invite code |
| `GET` | `/groups` | Get all groups for a user |
| `POST` | `/groups/:groupId/expenses` | Add an expense to a group |
| `GET` | `/groups/:groupId/expenses` | Get all expenses for a group |
| `PUT` | `/groups/:groupId/expenses/:expenseId` | Update an expense |
| `DELETE` | `/groups/:groupId/expenses/:expenseId` | Delete an expense |

---

## 📜 License
SplitMate is licensed under the **MIT License**. See [LICENSE](LICENSE) for more details.

---

## 📩 Contact & Support
💬 **Jonas Radke**  
📧 Email: [your-email@example.com](mailto:your-email@example.com)  
🌐 Portfolio: [jonasradke.dev](https://jonasradke.dev)  
🐙 GitHub: [jonasradke-dev](https://github.com/jonasradke-dev)

---

🚀 **Start splitting expenses the smart way with SplitMate today!** 🚀
