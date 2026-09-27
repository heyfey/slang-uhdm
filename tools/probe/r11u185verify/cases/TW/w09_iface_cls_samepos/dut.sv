// § tdKeyKeepsUnresolved176v § tfArgClassMethodOrder176
interface ifc;
  import pa::*;
  function automatic logic g(e_t v);
    return v == B;
  endfunction
endinterface
module top;
  ifc u();
  pb::k o;
  initial begin o = new; o.fff(pa::C); $display(u.g(pa::A)); end
endmodule
