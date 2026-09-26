`define TD(name, body) typedef struct packed { body } name;
`TD(s_t,
    logic [3:0] a;
    logic b;)
