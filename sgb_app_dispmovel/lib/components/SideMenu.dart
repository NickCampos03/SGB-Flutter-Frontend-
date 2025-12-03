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
    // Detecta se é mobile (largura menor que 600)
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      width: isMobile ? 70 : 240,
      height: double.infinity,
      padding: EdgeInsets.all(isMobile ? 8 : 16),
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
              SizedBox(height: isMobile ? 5 : 10),
              Text(
                "SGB",
                style: TextStyle(
                  fontSize: isMobile ? 20 : 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6366F1),
                  letterSpacing: 1,
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(height: 2),
                const Text(
                  "Sistema de Gerenciamento\nde Biblioteca",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],

              SizedBox(height: isMobile ? 8 : 16),

              Container(
                width: isMobile ? 40 : 160,
                height: isMobile ? 3 : 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              SizedBox(height: isMobile ? 15 : 30),

              _menuButton(
                context: context,
                icon: Icons.book,
                title: "Livros",
                isSelected: selected == 'livros',
                onTap: () => onSelect('livros'),
              ),

              if (perfil == 'ADMIN' || perfil == 'BIBLIOTECARIO')
                _menuButton(
                  context: context,
                  icon: Icons.bookmark,
                  title: "Gêneros",
                  isSelected: selected == 'generos',
                  onTap: () => onSelect('generos'),
                ),

              _menuButton(
                context: context,
                icon: Icons.assignment,
                title: "Empréstimos",
                isSelected: selected == 'emprestimos',
                onTap: () => onSelect('emprestimos'),
              ),

              if (perfil == 'ADMIN' || perfil == 'BIBLIOTECARIO')
                _menuButton(
                  context: context,
                  icon: Icons.people,
                  title: "Usuários",
                  isSelected: selected == 'usuarios',
                  onTap: () => onSelect('usuarios'),
                ),
            ],
          ),

          // Perfil
          Tooltip(
            message: 'Ver Perfil',
            child: GestureDetector(
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
          ),
        ],
      ),
    );
  }

  Widget _menuButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 6 : 10),
      child: Tooltip(
        message: isMobile ? title : '',
        child: Material(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 10 : 12,
                horizontal: isMobile ? 8 : 12,
              ),
              child: isMobile
                  ? Center(
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                        size: 24,
                      ),
                    )
                  : Row(
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
      ),
    );
  }
}
