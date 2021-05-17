import React from 'react';
import Square from './Square';
import Clue from './Clue';

class Board extends React.Component {
    render() {
        const numOfRows = this.props.grid.length;
        const numOfCols = this.props.grid[0].length;

        const rowClues = this.props.rowClues;
        const colClues = this.props.colClues;

        const rowStates = this.props.rowStates;
        const colStates = this.props.colStates;
        return (
            <div className="vertical">
                <div
                    className="colClues"
                    style={{
                        gridTemplateRows: '90px',
                        gridTemplateColumns: '90px repeat(' + numOfCols + ', 90px)'
                        /*
                           60px  40px 40px 40px 40px 40px 40px 40px   (gridTemplateColumns)
                          ______ ____ ____ ____ ____ ____ ____ ____
                         |      |    |    |    |    |    |    |    |  60px
                         |      |    |    |    |    |    |    |    |  (gridTemplateRows)
                          ------ ---- ---- ---- ---- ---- ---- ---- 
                         */
                    }}
                >
                    <div>{/* top-left corner square */}</div>
                    {colClues.map((clue, i) =>
                        <Clue 
                        clue={clue} 
                        key={i}
                        satisfied={colStates[i]}
                        />
                    )}
                </div>
                <div className="horizontal">
                    <div
                        className="rowClues"
                        style={{
                            gridTemplateRows: 'repeat(' + numOfRows + ', 90px)',
                            gridTemplateColumns: '90px'
                            /* IDEM column clues above */
                        }}
                    >
                        {rowClues.map((clue, i) =>
                            <Clue 
                            clue={clue} 
                            key={i}
                            satisfied={rowStates[i]}
                            />
                        )}

                    </div>
                    <div className="board"
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
                </div>   
            </div>
            
        );
        
    }    
}
export default Board;