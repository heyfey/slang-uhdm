// § ifcTaskFixupWalksAllStmts454
interface bfm(input logic clk, output logic [7:0] a, output logic [7:0] b, input logic rdy, input logic [1:0] sel);
  logic [3:0] cnt;
  task drive(input int x);
    if (x == 0) begin
      a <= 8'h1;
    end
    if (rdy) b <= 8'h2;
    else b <= 8'h3;
    case (sel)
      2'd0: cnt = 4'd1;
      default: cnt = 4'd2;
    endcase
    forever begin
      @(posedge clk);
      if (cnt == 4'd3) break;
      cnt = cnt + 1;
    end
    do begin
      a = a + 1;
    end while (a != 8'h4);
  endtask
endinterface
module top;
  logic clk, rdy;
  logic [7:0] a, b;
  logic [1:0] sel;
  bfm u(.clk(clk), .a(a), .b(b), .rdy(rdy), .sel(sel));
endmodule
