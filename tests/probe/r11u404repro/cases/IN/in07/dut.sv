// § implicitNetDefLastRef404
module mux_from_gates ();
reg c0, c1, c2, c3, A, B;
wire Y;
not (a_inv, A);
not (b_inv, B);
and (y0, c0, a_inv, b_inv);
and (y1, c1, a_inv, B);
and (y2, c2, A, b_inv);
and (y3, c3, A, B);
or (Y, y0, y1, y2, y3);
initial $display("%b", Y);
endmodule
