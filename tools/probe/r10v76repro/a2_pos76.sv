// r10v76 arm a2 -- THE POSITIONS g1 LEAVES UNMEASURED.
//   FOREVER body            (README claims golden folds -- never built in g1)
//   CASE EXPRESSION         (g1 measures only the case ITEM)
//   a for-init with SEVERAL declared vars
//   a nested for at DEPTH 3
//   an IF-ELSE branch beside a loop
//   a FUNCTION-CALL ARGUMENT inside a for body
//   a SELECT INDEX inside a for body
//   an ASSIGNMENT PATTERN inside a for body
//   a DELAY control and an event control inside a for body
//   a for statement whose ONLY read is in the STEP
//   a `for` with an empty header beside a repeat COUNT
// Row A is the MODULE-BODY twin of every one of them.
package v76p2;
  parameter int NB = 4;
endpackage

function automatic int v76f(input int x); return x + 1; endfunction

module v76body2 (input logic clk, output logic [31:0] o);   // MODULE-BODY twin
  import v76p2::*;
  logic [31:0] a1, a2, a3, a4;
  logic [31:0] arr [0:7];
  logic [31:0] pk [0:1];
  always_comb begin
    a1 = '0;
    case (NB)                                    // CASE EXPRESSION
      4: a1 = a1 + 1;
      default: a1 = a1 + 2;
    endcase
    for (int i = 0, int j = NB; i < 2; i++) a1 = a1 + j;   // multi-var init
    for (int i = 0; i < 2; i++)
      for (int j = 0; j < 2; j++)
        for (int k = 0; k < NB; k++) a1 = a1 + 1;          // depth-3 nested for
  end
  always_comb begin
    a2 = '0;
    for (int i = 0; i < 2; i++) begin
      a2 = a2 + v76f(NB);                        // call ARGUMENT in a for body
      a2 = a2 + arr[NB-1];                       // SELECT INDEX in a for body
      pk = '{NB, NB};                            // ASSIGNMENT PATTERN
      if (i == 0) a2 = a2 + NB; else a2 = a2 + 1;// IF-ELSE branch
    end
  end
  always_comb begin
    a3 = '0;
    for (int i = 0; i < 2; i = i + NB) a3 = a3 + 1;   // read ONLY in the STEP
  end
  initial begin
    a4 = 0;
    forever begin                                 // FOREVER body
      @(posedge clk) a4 = a4 + NB;
    end
  end
  assign o = a1 ^ a2 ^ a3 ^ a4;
endmodule

module v76gen2 #(parameter int P = 2) (input logic clk, output logic [31:0] o);
  import v76p2::*;
  logic [31:0] b1, b2, b3, b4;
  logic [31:0] arr [0:7];
  logic [31:0] pk [0:1];

  if (P > 0) begin : gg_a
    always_comb begin
      b1 = '0;
      case (NB)                                   // CASE EXPRESSION in gen
        4: b1 = b1 + 1;
        default: b1 = b1 + 2;
      endcase
      for (int i = 0, int j = NB; i < 2; i++) b1 = b1 + j;   // multi-var init
      for (int i = 0; i < 2; i++)
        for (int j = 0; j < 2; j++)
          for (int k = 0; k < NB; k++) b1 = b1 + 1;          // depth-3
    end
    always_comb begin
      b2 = '0;
      for (int i = 0; i < 2; i++) begin
        b2 = b2 + v76f(NB);                       // call ARGUMENT
        b2 = b2 + arr[NB-1];                      // SELECT INDEX
        pk = '{NB, NB};                           // ASSIGNMENT PATTERN
        if (i == 0) b2 = b2 + NB; else b2 = b2 + 1;
      end
    end
    always_comb begin
      b3 = '0;
      for (int i = 0; i < 2; i = i + NB) b3 = b3 + 1;   // STEP only
    end
    initial begin
      b4 = 0;
      forever begin                               // FOREVER body in a gen scope
        @(posedge clk) b4 = b4 + NB;
      end
    end
  end

  assign o = b1 ^ b2 ^ b3 ^ b4;
endmodule

module v76top2 (input logic clk, output logic [31:0] o1, output logic [31:0] o2);
  v76body2 u_b (.clk(clk), .o(o1));
  v76gen2 #(2) u_g (.clk(clk), .o(o2));
endmodule
