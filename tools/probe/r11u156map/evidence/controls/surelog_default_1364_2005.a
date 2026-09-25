0	design	work@main				0	0	0	0				
1	package	builtin	builtin	builtin::		0	0	0	0				
1	package	builtin	builtin	builtin::		0	0	0	0				
2	class_defn	any_sverilog_class		builtin::any_sverilog_class		0	0	0	0				
2	class_defn	array		builtin::array		0	0	0	0				
2	class_defn	queue		builtin::queue		0	0	0	0				
2	class_defn	string		builtin::string		0	0	0	0				
2	class_defn	system		builtin::system		0	0	0	0				
1	class_defn	work@mailbox			builtin.sv	1	3	27	11				
2	function	new		work@mailbox::new	builtin.sv	3	5	4	16				
3	class_var			work@mailbox::new	builtin.sv	3	23	3	28		0		
4	ref_typespec			work@mailbox::new		0	0	0	0		0		
5	class_typespec					0	0	0	0				
3	io_decl	bound			builtin.sv	3	23	3	28				
4	constant				builtin.sv	3	31	3	32	0	64	UINT:0	9
4	ref_typespec			work@mailbox::new::bound		0	0	0	0		0		
5	int_typespec				builtin.sv	3	19	3	22				
2	function	num		work@mailbox::num	builtin.sv	6	5	7	16				
3	int_var			work@mailbox::num	builtin.sv	6	14	6	17		0		
4	ref_typespec			work@mailbox::num		0	0	0	0		0		
5	int_typespec				builtin.sv	6	14	6	17				
2	task	put		work@mailbox::put	builtin.sv	9	5	10	12				
3	io_decl	message			builtin.sv	9	15	9	22				
2	function	try_put		work@mailbox::try_put	builtin.sv	12	5	13	16				
3	logic_var			work@mailbox::try_put		0	0	0	0		0		
3	io_decl	message			builtin.sv	12	23	12	30				
2	task	get		work@mailbox::get	builtin.sv	15	5	16	12				
3	io_decl	message			builtin.sv	15	19	15	26				
2	function	try_get		work@mailbox::try_get	builtin.sv	18	5	19	16				
3	int_var			work@mailbox::try_get	builtin.sv	18	14	18	17		0		
4	ref_typespec			work@mailbox::try_get		0	0	0	0		0		
5	int_typespec				builtin.sv	18	14	18	17				
3	io_decl	message			builtin.sv	18	31	18	38				
2	task	peek		work@mailbox::peek	builtin.sv	21	5	22	12				
3	io_decl	message			builtin.sv	21	20	21	27				
2	function	try_peek		work@mailbox::try_peek	builtin.sv	24	5	25	16				
3	int_var			work@mailbox::try_peek	builtin.sv	24	14	24	17		0		
4	ref_typespec			work@mailbox::try_peek		0	0	0	0		0		
5	int_typespec				builtin.sv	24	14	24	17				
3	io_decl	message			builtin.sv	24	31	24	38				
1	class_defn	work@process			builtin.sv	30	3	52	11				
2	enum_typespec	state			builtin.sv	32	5	32	74				
3	enum_const	FINISHED			builtin.sv	32	20	32	28				
3	enum_const	RUNNING			builtin.sv	32	30	32	37				
3	enum_const	WAITING			builtin.sv	32	39	32	46				
3	enum_const	SUSPENDED			builtin.sv	32	48	32	57				
3	enum_const	KILLED			builtin.sv	32	59	32	65				
2	function	self		work@process::self	builtin.sv	34	5	34	11				
3	class_var			work@process::self	builtin.sv	34	21	34	28		0		
4	ref_typespec			work@process::self		0	0	0	0		0		
5	class_typespec				builtin.sv	34	21	34	28				
2	function	status		work@process::status	builtin.sv	37	5	38	16				
3	enum_var			work@process::status	builtin.sv	37	14	37	19		0		
4	ref_typespec			work@process::status		0	0	0	0		0		
5	enum_typespec	state			builtin.sv	32	5	32	74				
6	enum_const	FINISHED			builtin.sv	32	20	32	28				
6	enum_const	RUNNING			builtin.sv	32	30	32	37				
6	enum_const	WAITING			builtin.sv	32	39	32	46				
6	enum_const	SUSPENDED			builtin.sv	32	48	32	57				
6	enum_const	KILLED			builtin.sv	32	59	32	65				
2	task	kill		work@process::kill	builtin.sv	40	5	41	12				
2	task	await		work@process::await	builtin.sv	43	5	44	12				
2	task	suspend		work@process::suspend	builtin.sv	46	5	47	12				
2	task	resume		work@process::resume	builtin.sv	49	5	50	12				
1	class_defn	work@semaphore			builtin.sv	55	3	69	11				
2	function	new		work@semaphore::new	builtin.sv	57	5	58	16				
3	class_var			work@semaphore::new	builtin.sv	57	22	57	30		0		
4	ref_typespec			work@semaphore::new		0	0	0	0		0		
5	class_typespec					0	0	0	0				
3	io_decl	keyCount			builtin.sv	57	22	57	30				
4	constant				builtin.sv	57	33	57	34	0	64	UINT:0	9
4	ref_typespec			work@semaphore::new::keyCount		0	0	0	0		0		
5	int_typespec				builtin.sv	57	18	57	21				
2	task	put		work@semaphore::put	builtin.sv	60	5	61	12				
3	io_decl	keyCount			builtin.sv	60	18	60	26				
4	constant				builtin.sv	60	29	60	30	1	64	UINT:1	9
4	ref_typespec			work@semaphore::put::keyCount		0	0	0	0		0		
5	int_typespec				builtin.sv	60	14	60	17				
2	task	get		work@semaphore::get	builtin.sv	63	5	64	12				
3	io_decl	keyCount			builtin.sv	63	18	63	26				
4	constant				builtin.sv	63	29	63	30	1	64	UINT:1	9
4	ref_typespec			work@semaphore::get::keyCount		0	0	0	0		0		
5	int_typespec				builtin.sv	63	14	63	17				
2	function	try_get		work@semaphore::try_get	builtin.sv	66	5	67	16				
3	int_var			work@semaphore::try_get	builtin.sv	66	14	66	17		0		
4	ref_typespec			work@semaphore::try_get		0	0	0	0		0		
5	int_typespec				builtin.sv	66	14	66	17				
3	io_decl	keyCount			builtin.sv	66	30	66	38				
4	constant				builtin.sv	66	41	66	42	1	64	UINT:1	9
4	ref_typespec			work@semaphore::try_get::keyCount		0	0	0	0		0		
5	int_typespec				builtin.sv	66	26	66	29				
1	module_inst		work@main	work@main	dut.v	3	1	11	10				
2	logic_net	foo		work@main.foo	dut.v	5	14	5	17		0		
3	ref_typespec			work@main.foo		0	0	0	0		0		
4	logic_typespec				dut.v	5	4	5	13				
5	range				dut.v	5	8	5	13				
6	constant				dut.v	5	9	5	10	3	64	UINT:3	9
6	constant				dut.v	5	11	5	12	0	64	UINT:0	9
2	logic_net	bar		work@main.bar	dut.v	5	19	5	22		0		
3	ref_typespec			work@main.bar		0	0	0	0		0		
4	logic_typespec				dut.v	5	4	5	13				
5	range				dut.v	5	8	5	13				
6	constant				dut.v	5	9	5	10	3	64	UINT:3	9
6	constant				dut.v	5	11	5	12	0	64	UINT:0	9
2	logic_net	adr		work@main.adr	dut.v	6	14	6	17		0		
3	ref_typespec			work@main.adr		0	0	0	0		0		
4	logic_typespec				dut.v	6	4	6	13				
5	range				dut.v	6	8	6	13				
6	constant				dut.v	6	9	6	10	1	64	UINT:1	9
6	constant				dut.v	6	11	6	12	0	64	UINT:0	9
2	logic_net	bit		work@main.bit	dut.v	8	13	8	16		0		
3	ref_typespec			work@main.bit		0	0	0	0		0		
4	logic_typespec				dut.v	8	4	8	7				
2	logic_net	rst		work@main.rst	dut.v	8	18	8	21		0		
3	ref_typespec			work@main.rst		0	0	0	0		0		
4	logic_typespec				dut.v	8	4	8	7				
2	logic_net	clk		work@main.clk	dut.v	8	23	8	26		0		
3	ref_typespec			work@main.clk		0	0	0	0		0		
4	logic_typespec				dut.v	8	4	8	7				
2	logic_net	load_enable		work@main.load_enable	dut.v	9	13	9	24		0		
3	ref_typespec			work@main.load_enable		0	0	0	0		0		
4	logic_typespec				dut.v	9	4	9	7				
2	logic_net	write_enable		work@main.write_enable	dut.v	9	26	9	38		0		
3	ref_typespec			work@main.write_enable		0	0	0	0		0		
4	logic_typespec				dut.v	9	4	9	7				
1	module_inst	work@main	work@main		dut.v	3	1	11	10				
2	logic_net	foo		work@main.foo	dut.v	5	14	5	17		0		
3	ref_typespec			work@main.foo		0	0	0	0		0		
4	logic_typespec				dut.v	5	4	5	13				
5	range				dut.v	5	8	5	13				
6	constant				dut.v	5	9	5	10	3	64	UINT:3	9
6	constant				dut.v	5	11	5	12	0	64	UINT:0	9
2	logic_net	bar		work@main.bar	dut.v	5	19	5	22		0		
3	ref_typespec			work@main.bar		0	0	0	0		0		
4	logic_typespec				dut.v	5	4	5	13				
5	range				dut.v	5	8	5	13				
6	constant				dut.v	5	9	5	10	3	64	UINT:3	9
6	constant				dut.v	5	11	5	12	0	64	UINT:0	9
2	logic_net	adr		work@main.adr	dut.v	6	14	6	17		0		
3	ref_typespec			work@main.adr		0	0	0	0		0		
4	logic_typespec				dut.v	6	4	6	13				
5	range				dut.v	6	8	6	13				
6	constant				dut.v	6	9	6	10	1	64	UINT:1	9
6	constant				dut.v	6	11	6	12	0	64	UINT:0	9
2	logic_net	bit		work@main.bit	dut.v	8	13	8	16		0		
3	ref_typespec			work@main.bit		0	0	0	0		0		
4	logic_typespec				dut.v	8	4	8	7				
2	logic_net	rst		work@main.rst	dut.v	8	18	8	21		0		
3	ref_typespec			work@main.rst		0	0	0	0		0		
4	logic_typespec				dut.v	8	4	8	7				
2	logic_net	clk		work@main.clk	dut.v	8	23	8	26		0		
3	ref_typespec			work@main.clk		0	0	0	0		0		
4	logic_typespec				dut.v	8	4	8	7				
2	logic_net	load_enable		work@main.load_enable	dut.v	9	13	9	24		0		
3	ref_typespec			work@main.load_enable		0	0	0	0		0		
4	logic_typespec				dut.v	9	4	9	7				
2	logic_net	write_enable		work@main.write_enable	dut.v	9	26	9	38		0		
3	ref_typespec			work@main.write_enable		0	0	0	0		0		
4	logic_typespec				dut.v	9	4	9	7				
