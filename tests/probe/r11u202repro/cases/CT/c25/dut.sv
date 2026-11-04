// § classSpecExprArgUnlocated202
virtual class obj; endclass
class cfg#(type T=int, type T2=int);
endclass
module top ();
  cfg#(obj, string) a = new;
  cfg#(string, obj) b;
endmodule
