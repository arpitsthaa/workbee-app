p = 'D:/Workbee/workbee_frontend/lib/views/my_work_screen.dart'
s = open(p, encoding='utf-8').read()

old = """                              const Text(
                                'My work',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: darkText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Follow your progress. Keep work moving.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: mutedText,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container("""

new = """                              Container("""

print('found', old in s)
if old in s:
    s = s.replace(old, new, 1)
    open(p, 'w', encoding='utf-8').write(s)
    print('done')