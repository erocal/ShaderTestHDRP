using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateAroundPoint : MonoBehaviour
{

    #region -- 資源參考區 --

    public Transform centerPoint; // 旋轉的中心點
    public float speed = 10f;     // 旋轉速度

    #endregion

    #region -- 變數參考區 --

    #endregion

    #region -- 初始化/運作 --

    private void Awake()
	{
		
	}

	private void Update()
	{

        // 繞著中心點旋轉
        transform.RotateAround(centerPoint.position, Vector3.up, speed * Time.deltaTime);

    }

	#endregion
	
	#region -- 方法參考區 --

	#endregion
	
}
