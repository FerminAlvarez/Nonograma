import React from 'react';

class Clue extends React.Component {
    render() {
        const clue = this.props.clue;
        const satisfied = this.props.satisfied;
        return (
            <div className={"clue" + (satisfied ? "-sat" : "")}>
                {clue.map((num, i) =>
                    <div key={i}>
                        {num}
                    </div>
                )}
            </div>
        );
    }
}


export default Clue;