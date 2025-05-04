import 'package:flutter/material.dart';
import '../../models/recruiter_account_model.dart';
import '../../services/account_service.dart';

enum AccountType { user, recruiter }

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<RecruiterAccount> _accounts = [];
  bool _isLoading = true;
  AccountType _selectedType = AccountType.recruiter;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    _accounts = await AccountService.fetchAccountsByRole(
      _selectedType == AccountType.recruiter ? 'recruiter' : 'job_seeker',
    );
    setState(() => _isLoading = false);
  }

  Future<void> _approveAccount(String id) async {
    final success = await AccountService.updateApproval(id, true);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Đã duyệt thành công'))),
      );
      _loadAccounts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duyệt tài khoản thất bại.')),
      );
    }
  }

  Future<void> _toggleActive(String id, bool isActive) async {
    final success = await AccountService.updateActiveStatus(id, !isActive);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(isActive ? 'Đã khóa tài khoản' : 'Đã mở khóa tài khoản'),
        ),
      );
      _loadAccounts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật trạng thái thất bại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
        actions: [
          DropdownButton<AccountType>(
            value: _selectedType,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            dropdownColor: Colors.white,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedType = value);
                _loadAccounts();
              }
            },
            items: const [
              DropdownMenuItem(value: AccountType.user, child: Text('User')),
              DropdownMenuItem(
                  value: AccountType.recruiter, child: Text('Recruiter')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? const Center(child: Text('Không có tài khoản nào.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _accounts.length,
                  itemBuilder: (context, index) {
                    final account = _accounts[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: account.avatar != null
                              ? NetworkImage(account.avatar!)
                              : const AssetImage('assets/images/logo_1.jpg')
                                  as ImageProvider,
                        ),
                        title: Text(account.name ?? 'Chưa có tên'),
                        subtitle: Text(account.email),
                        trailing: SizedBox(
                          height: 90,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!account.isApproved)
                                  ElevatedButton(
                                    onPressed: () =>
                                        _approveAccount(account.id),
                                    child: const Text('Approved'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      minimumSize: const Size(80, 32),
                                    ),
                                  )
                                else ...[
                                  Text(
                                    account.isActive
                                        ? 'Active'
                                        : 'locked',
                                    style: TextStyle(
                                      color: account.isActive
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _toggleActive(
                                        account.id, account.isActive),
                                    child:
                                        Text(account.isActive ? 'lock' : 'Open'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
