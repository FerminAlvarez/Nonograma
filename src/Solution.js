import React from 'react';
import Square from './Square';

class Board extends React.Component {
    render() {
        const numOfRows = this.props.grid.length;
        const numOfCols = this.props.grid[0].length;
        return (
                <div className="boardSolution"
                    style={{
                        gridTemplateRows: 'repeat(' + numOfRows + ', 90px)',
                        gridTemplateColumns: 'repeat(' + numOfCols + ', 90px)'
                    }}>
                    {this.props.grid.map((row, i) =>
                        row.map((cell, j) =>
                            <Square
                                value={cell}
                                onClick={() => this.props.onClick(i, j)}
                                key={i + j}
                            />
                        )
                    )}
                </div>
            
        );
        
    }    
}
export default Board;