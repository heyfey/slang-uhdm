// § classSpecPaNoFile152
class resource #(type T=int);
  T v;
endclass
module top ();
  function automatic int f(resource#(byte) r);
    return 0;
  endfunction
  int k = f(null);
endmodule
