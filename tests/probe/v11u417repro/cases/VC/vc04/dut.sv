// § foreachArrayNamesClass417
class b;
  int v;
endclass
program top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endprogram
