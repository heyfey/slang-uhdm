// § procReplCountOwner254 (control: the module's own localparam and header parameter as replication counts in a process)
module top #(parameter int HP = 3);
  localparam int LP = 3;
  logic [5:0] q, r;
  always_comb begin q = {LP{2'b10}}; r = {HP{2'b01}}; end
endmodule
