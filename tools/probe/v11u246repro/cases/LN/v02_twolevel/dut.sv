// § contLvMidSelNetBase246
package hp;
  typedef struct packed { logic [7:0] d; } key_t;
  typedef struct packed { key_t [3:0] key; logic v; } s_t;
endpackage
module m import hp::*; #(parameter bit EN = 1) (output logic [7:0] o);
  if (EN) begin : ga
    wire s_t w;
    for (genvar i = 0; i < 2; i++) begin : gb
      assign w.key[i].d = 8'(i);
      assign w.key[i + 2].d = 8'(-i);
    end
    assign w.v = 1'b1;
    assign o = w.key[1].d;
  end else begin : gc
    assign o = '0;
  end
endmodule
module mid(output logic [7:0] o);
  m u(.o(o));
endmodule
module top(output logic [7:0] o);
  mid mm(.o(o));
endmodule
