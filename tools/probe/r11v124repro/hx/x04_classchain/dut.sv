// § incDecMemberPathIsLvalue124
class E; int n; endclass
class D; E e; endclass
class C; D d; function void f(); d.e.n++; endfunction endclass
