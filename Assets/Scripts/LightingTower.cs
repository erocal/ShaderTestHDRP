using UnityEngine;

public class LightingTower : MonoBehaviour
{

	#region -- 資源參考區 --

	[SerializeField] private GameObject target;
    [SerializeField] private GameObject lightingVFX;
    [SerializeField] private Transform hitTargetPos;
    [SerializeField] private float lightingDistance = 20f;

    #endregion

    #region -- 變數參考區 --

    #endregion

    #region -- 初始化/運作 --

    private void Awake()
	{
		
	}

	private void Update()
	{

		if (target == null || lightingVFX == null)
		{
			Debug.LogError("目標或VFX沒有放置");
			return;
		}

		transform.LookAt(target.transform.position);

		ActiveLighting();

	}

	#endregion
	
	#region -- 方法參考區 --

	/// <summary>
	/// 啟動電擊
	/// </summary>
	private void ActiveLighting()
	{

		lightingVFX.SetActive(
			Vector3.Distance(target.transform.position, transform.position) 
			<= lightingDistance
            );

		MoveLightingPos();

    }

    /// <summary>
	/// 移動電擊擊中目標的位置
	/// </summary>
	private void MoveLightingPos()
	{

        RaycastHit hit;

        if (Physics.Raycast(transform.position, transform.forward, out hit))
        {

            hitTargetPos.position = hit.point;
            // 在場景中顯示射線（僅為了調試用）
            Debug.DrawRay(transform.position, transform.forward * hit.distance, Color.green);

        }
        else
        {
            // 如果沒有打到物體，顯示射線的最大長度（可以自行調整）
            Debug.DrawRay(transform.position, transform.forward * 1000, Color.red);
        }

    }

    #endregion

}