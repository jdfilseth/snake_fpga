// Board parameters (cannot be modified without significant revisions to code)
parameter	BOARD_WIDTH		=	39;
parameter	BOARD_HEIGHT	=	29;
parameter	BOARD_WIDTH_BITS	=	6; // must be >= log2(BOARD_WIDTH)
parameter	BOARD_HEIGHT_BITS	=	5; // must be >= log2(BOARD_HEIGHT)

// Number of squares the snake gets longer every time it eats a dot (can be modified)
parameter 	GROWTH_RATE		=	2;
parameter	START_SPEED		= 	3000000;

// VGA parameters (cannot be modified without significant revisions to code)
parameter	MESSAGE_BORDER 		= 15;
parameter	VIDEO_W				= 640;
parameter	VIDEO_H				= 480;
parameter 	CELL_SIZE 			= 16;
