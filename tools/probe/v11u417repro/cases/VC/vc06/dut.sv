// § foreachArrayNamesClass417
interface ifc;
  class b;
    int v;
  endclass
  int b2;
  int n;
  task t();
    int b[2];
    foreach (b[k]) n += k;
  endtask
endinterface
module top;
  ifc u();
endmodule
