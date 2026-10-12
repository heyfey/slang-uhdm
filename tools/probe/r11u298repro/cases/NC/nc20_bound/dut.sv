// § nestedCastOuterTpPlaceholder298
// constant slot: the cast in a part-select bound and a replication count
module top #(parameter type T = logic [2:0]) (input logic [7:0] a, output logic [7:0] y);
  module inner (input logic [7:0] b, output logic [7:0] z);
    assign z = {b[T'(3):0], {T'(4){1'b0}}};
  endmodule
  inner u (.b(a), .z(y));
endmodule
