// residue (no law landed): a program foreach loop variable, see README
program top;
  int b[3];
  int n;
  initial begin foreach (b[i]) n += b[i]; end
endprogram
