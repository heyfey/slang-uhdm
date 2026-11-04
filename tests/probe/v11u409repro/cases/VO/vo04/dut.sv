// § oobEventTrigHoistNet409
class c;
  event e;
  extern function void f();
endclass
function void c::f();
  -> e;
endfunction
module top;
endmodule
