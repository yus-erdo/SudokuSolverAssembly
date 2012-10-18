#include <iostream>

using namespace std;

extern "C" {
	void SolveSudoku(int sudokuBoard[][9]);
}


int main(void) {

	int sudokuBoard[9][9]={0};
	
	//sudoku example 1
	//
	// only some of the cells are initialized
	sudokuBoard[0][0] = 6;
	sudokuBoard[0][2] = 4;
	sudokuBoard[0][7] = 3;
	sudokuBoard[1][2] = 5;
	sudokuBoard[1][3] = 7;
	sudokuBoard[1][5] = 3;
	sudokuBoard[1][6] = 6;
	sudokuBoard[2][0] = 2;
	sudokuBoard[2][1] = 3;
	sudokuBoard[2][3] = 5;
	sudokuBoard[2][5] = 4;
	sudokuBoard[2][6] = 8;
	sudokuBoard[2][8] = 1;
	sudokuBoard[3][1] = 6;
	sudokuBoard[3][3] = 8;
	sudokuBoard[3][4] = 1;
	sudokuBoard[3][5] = 2;
	sudokuBoard[4][2] = 2;
	sudokuBoard[4][6] = 7;
	sudokuBoard[5][3] = 9;
	sudokuBoard[5][4] = 7;
	sudokuBoard[5][5] = 6;
	sudokuBoard[5][7] = 5;
	sudokuBoard[6][0] = 7;
	sudokuBoard[6][2] = 6;
	sudokuBoard[6][3] = 1;
	sudokuBoard[6][5] = 8;
	sudokuBoard[6][7] = 9;
	sudokuBoard[6][8] = 2;
	sudokuBoard[7][2] = 8;
	sudokuBoard[7][3] = 4;
	sudokuBoard[7][5] = 9;
	sudokuBoard[7][6] = 1;
	sudokuBoard[8][1] = 2;
	sudokuBoard[8][6] = 4;
	sudokuBoard[8][8] = 5;
	


	

	for(int i=0;i<9;i++)
	{
		for(int j=0;j<9;j++)
		{			
			cout << sudokuBoard[i][j];
			cout << " ";
		}
		cout << "\n";
	}
	
	cout << "\n\n\n\n\n";
	
	SolveSudoku(sudokuBoard);

	for(int i=0;i<9;i++)
	{
		for(int j=0;j<9;j++)
		{			
			cout << sudokuBoard[i][j];
			cout << " ";
		}
		cout << "\n";
	}

	int i =0;
	scanf("%d",&i);
	
	
}