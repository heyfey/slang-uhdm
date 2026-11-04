// § multiDeclOneItem140
interface ifc;
  function automatic int h(input int v);
    int a;
    int b, c;
    a = v; b = a; c = b;
    return c;
  endfunction
endinterface
module dut;
  ifc u();
endmodule
