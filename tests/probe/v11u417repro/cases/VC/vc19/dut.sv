// § foreachArrayNamesClass417
class b;
  int v;
endclass
class A;
  int n;
  task t();
    int b[$];
    b.push_back(1);
    foreach (b[i]) begin
      n += i;
      n += b[i];
    end
  endtask
endclass
module top;
endmodule
