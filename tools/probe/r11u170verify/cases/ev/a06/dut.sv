// § enumAliasEndAtDimOrInitDecl158
package pkg; typedef enum logic [3:0] { ONE, TWO, SIX = 6 } enum_t; typedef enum_t alias_t; endpackage
module leaf (output logic [3:0] o); pkg::alias_t b; assign b = pkg::TWO; assign o = b; endmodule
module mid (output logic [3:0] o); leaf l(.o(o)); endmodule
module dut (output logic [3:0] o); mid m(.o(o)); endmodule
