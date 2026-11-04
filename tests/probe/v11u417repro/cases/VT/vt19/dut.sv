// § foreachArrayNamesTypedef417
typedef int b;
program top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endprogram
