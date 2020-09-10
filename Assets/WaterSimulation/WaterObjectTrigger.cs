using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

[RequireComponent(typeof(BoxCollider))]
public class WaterObjectTrigger : MonoBehaviour
{
    [SerializeField] 
    private BoxCollider boxCollider = null;
    
    [SerializeField] 
    private WaterSimulation waterSimulation = null;

    [SerializeField] 
    private Vector2 minMaxSize = new Vector2(0.04f, 0.05f);

    [SerializeField] 
    private WaterSimulation.Mode mode = WaterSimulation.Mode.PushUp;
    
    private void OnTriggerStay(Collider other)
    {
        var center = other.bounds.center;
        var localCenter = center - transform.position;
        var normalizedPosition = new Vector2(-localCenter.x / boxCollider.size.x + 0.5f, localCenter.z / boxCollider.size.z + 0.5f);
        var size = Random.Range(minMaxSize.x, minMaxSize.y);
        waterSimulation.AddZone(mode, normalizedPosition, new Vector2(size, size));
    }
}
