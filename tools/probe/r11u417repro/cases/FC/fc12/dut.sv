// § foreachArrayNamesClass417
class b;
  int v;
endclass
module top;
  task automatic t();
    int b[$];
    int n;
    b.push_back(1);
    foreach (b[i]) n += b[i];
  endtask
  initial t();
endmodule
