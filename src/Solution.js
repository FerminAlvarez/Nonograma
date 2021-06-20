import React from 'react';
import SquareSolution from './SquareSolution';

class Board extends React.Component {
    render() {
        const numOfRows = this.props.grid.length;
        const numOfCols = this.props.grid[0].length;
        console.log("boardSolution"+ (this.props.isShowingSolution === true ? "" : "Hidden"));
        return (
                <div className={"boardSolution"+ (this.props.isShowingSolution === true ? "" : "Hidden")}
                    style={{
                        gridTemplateRows: 'repeat(' + numOfRows + ', 90px)',
                        gridTemplateColumns: 'repeat(' + numOfCols + ', 90px)'
                    }}>
                    {this.props.grid.map((row, i) =>
                        row.map((cell, j) =>
                            <SquareSolution
                                value={cell}
                                key={i + j}
                            />
                        )
                    )}
                </div>
            
        );
        
    }    
}
export default Board;