p = 'D:/Workbee/workbee_frontend/lib/views/passport_screen.dart'
s = open(p, encoding='utf-8').read()
i = s.find('child: Column(')
print(repr(s[i:i+900]))