// § tfBodyTypedefIsItem304
interface ifc;
  int q;
  function automatic int g(int x);
    int b;
    typedef bit [2:0] s_t;
    s_t v;
    v = x[2:0];
    return v + b;
  endfunction
endinterface
module top; ifc u(); endmodule
