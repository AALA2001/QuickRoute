import { LineWave } from 'react-loader-spinner'

function AdminPanelLoader() {
    return (
        <LineWave
            visible={true}
            height="180"
            width="170"
            color="#eb662b"
            ariaLabel="line-wave-loading"
            wrapperStyle={{  }}
            wrapperClass="loader-wrapper"
            firstLineColor="#eb662b"
            middleLineColor="#05073c"
            lastLineColor="#eb662b"
        />
    )
}

export default AdminPanelLoader
