// § tfItemInitLocalAtType209 — r11u217 l01: initialized locals of scalar types (byte, shortint, longint, bit signed, logic [3:0], time, realtime, shortreal, integer) in a paren-less package function
package p;
  function int f;
    byte b = 8'd1;
    shortint s = 16'd2;
    longint l = 64'd3;
    bit signed [3:0] t = -4'sd1;
    logic [3:0] v = 4'hA;
    time tm = 10;
    realtime rt = 1.5;
    shortreal sr = 2.0;
    integer ig = 7;
    return b + s + l + t + v + ig;
  endfunction
endpackage
module top (output int o);
  assign o = p::f();
endmodule
