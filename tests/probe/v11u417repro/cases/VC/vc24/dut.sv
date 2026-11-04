// § foreachArrayNamesClass417
program top;
  class b;
    int v;
  endclass
  int b2;
  int n;
  task t();
    int b[3];
    foreach (b[i]) n += i;
  endtask
  initial t();
endprogram
