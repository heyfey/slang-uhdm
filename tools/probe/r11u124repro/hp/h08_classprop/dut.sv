// § incDecMemberPathIsLvalue124
class D; int n; endclass
class C; D d; function void f(); d.n++; endfunction endclass
