import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final String perfil;
  final String selected;
  final Function(String) onSelect;

  const SideMenu({
    super.key,
    required this.perfil,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // Header
          Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "SGB",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Sistema de Gerenciamento\nde Biblioteca",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: 160,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 30),

              _menuButton(
                icon: Icons.book,
                title: "Livros",
                isSelected: selected == 'livros',
                onTap: () => onSelect('livros'),
              ),

              if (perfil == 'ADMIN' || perfil == 'BIBLIOTECARIO')
                _menuButton(
                  icon: Icons.bookmark,
                  title: "Gêneros",
                  isSelected: selected == 'generos',
                  onTap: () => onSelect('generos'),
                ),

              _menuButton(
                icon: Icons.assignment,
                title: "Empréstimos",
                isSelected: selected == 'emprestimos',
                onTap: () => onSelect('emprestimos'),
              ),

              if (perfil == 'ADMIN' || perfil == 'BIBLIOTECARIO')
                _menuButton(
                  icon: Icons.people,
                  title: "Usuários",
                  isSelected: selected == 'usuarios',
                  onTap: () => onSelect('usuarios'),
                ),
            ],
          ),

          // Perfil
          GestureDetector(
            onTap: () => onSelect('perfil'),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6366F1),
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/icons8-user-50.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
